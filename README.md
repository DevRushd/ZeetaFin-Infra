# GridSynk Infra — Production AWS VPC with ALB + ASG

Terraform configuration for a production-grade AWS environment with a VPC, Application Load Balancer (public subnets), and Auto Scaling Group (private subnets).

## Architecture

```
Internet
    │
    ├── ALB (port 80 / 443)
    │     ├── public subnet AZ-a
    │     └── public subnet AZ-b
    │
    ├── ASG (port 80 via ALB only)
    │     ├── private subnet AZ-a
    │     └── private subnet AZ-b
    │
    ├── NAT Gateway (outbound from private subnets)
    ├── VPC Flow Logs → CloudWatch
    └── CloudWatch Alarms → SNS (optional)
```

## Resources

| Component | Details |
|-----------|---------|
| **VPC** | `10.0.0.0/16` with DNS support |
| **Subnets** | 2 public (`10.0.0.0/24`, `10.0.1.0/24`), 2 private (`10.0.2.0/24`, `10.0.3.0/24`) across 2 AZs |
| **ALB** | Internet-facing, application load balancer in public subnets |
| **ASG** | Auto Scaling Group in private subnets, min/max/desired configurable |
| **NAT** | Single NAT Gateway in public subnet for private subnet egress |
| **SSM** | IAM role + instance profile for Systems Manager Session Manager access |
| **Flow Logs** | VPC Flow Logs capturing all traffic to CloudWatch Logs (default 30-day retention) |
| **Monitoring** | CloudWatch alarms for healthy host count, target 5xx, and ALB 5xx |

## Prerequisites

- Terraform >= 1.15
- AWS credentials configured (env vars, `~/.aws/credentials`, or IAM role)
- An existing EC2 key pair in the target region

## Quick Start

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region     = "eu-west-1"
vpc_cidr       = "10.0.0.0/16"
name_prefix    = "gridsynk"
my_ip          = "YOUR_IP/32"
instance_type  = "t3.small"
key_pair       = "YOUR_KEYPAIR_NAME"
```

Deploy:

```bash
terraform init
terraform plan
terraform apply
```

## Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `aws_region` | yes | — | AWS region |
| `name_prefix` | yes | — | Prefix for all resource names |
| `vpc_cidr` | yes | — | VPC CIDR block |
| `my_ip` | yes | — | Admin IP for security group references |
| `instance_type` | yes | — | EC2 instance type |
| `key_pair` | yes | — | EC2 key pair name |
| `asg_min_size` | no | `2` | Minimum ASG instances |
| `asg_max_size` | no | `6` | Maximum ASG instances |
| `asg_desired_capacity` | no | `2` | Desired ASG instances |
| `certificate_arn` | no | `null` | ACM certificate ARN for HTTPS listener |
| `enable_deletion_protection` | no | `false` | Enable ALB deletion protection |
| `flow_logs_retention_days` | no | `30` | CloudWatch log retention for flow logs |
| `alarm_arn` | no | `null` | SNS topic ARN for alarm notifications |

## Outputs

| Output | Description |
|--------|-------------|
| `alb_dns_name` | ALB DNS name |
| `alb_zone_id` | Route 53 zone ID for the ALB |
| `asg_name` | Auto Scaling Group name |
| `vpc_id` | VPC ID |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `app_security_group_id` | App instance security group ID |
| `https_listener_arn` | HTTPS listener ARN (null if not configured) |
| `state_bucket` | S3 bucket for Terraform remote state |
| `dynamodb_lock_table` | DynamoDB table for state locking |
| `flow_log_group` | CloudWatch log group for VPC Flow Logs |
| `cw_alarm_healthy_hosts` | CloudWatch alarm ARN for healthy host count |

## Migrating to Remote State

After the first `terraform apply`, the S3 bucket and DynamoDB table exist. To migrate state:

1. Create `backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "<name_prefix>-terraform-state-<account_id>-<region>"
    key            = "terraform.tfstate"
    region         = "<region>"
    dynamodb_table = "<name_prefix>-terraform-locks"
    encrypt        = true
  }
}
```

2. Run:
```bash
terraform init -migrate-state
```

## Accessing Private Instances

Instances in private subnets have the SSM IAM role attached. Use AWS Systems Manager Session Manager instead of SSH:

```bash
aws ssm start-session --target <instance-id>
```

No bastion host, no open SSH ports, no public IPs needed.

## Security

- App instances accept traffic **only from the ALB security group**
- ALB accepts HTTP/HTTPS from the internet
- No public IPs on private instances
- S3 backend bucket is versioned, encrypted, and public access blocked
- VPC Flow Logs for network audit trail

## HTTPS Setup

To enable HTTPS, set `certificate_arn` in `terraform.tfvars` to a free ACM certificate ARN:

```hcl
certificate_arn = "arn:aws:acm:eu-west-1:123456789012:certificate/xxxx-xxxx-xxxx"
```

ACM certificates in the same region as the ALB are free of charge. When set, an HTTPS listener on port 443 is created alongside the existing HTTP listener.
