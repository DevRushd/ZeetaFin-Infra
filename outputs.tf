output "alb_dns_name" {
  description = "ALB DNS name for the application"
  value       = aws_lb.app.dns_name
}

output "alb_zone_id" {
  description = "ALB Route 53 zone ID"
  value       = aws_lb.app.zone_id
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app.name
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.lab.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "app_security_group_id" {
  description = "App instance security group ID"
  value       = aws_security_group.app.id
}

output "https_listener_arn" {
  description = "HTTPS listener ARN (null if not configured)"
  value       = try(aws_lb_listener.https[0].arn, null)
}

output "state_bucket" {
  description = "S3 bucket for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_lock_table" {
  description = "DynamoDB table for Terraform state locking"
  value       = aws_dynamodb_table.terraform_locks.name
}

output "flow_log_group" {
  description = "CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.flow_logs.name
}

output "cw_alarm_healthy_hosts" {
  description = "CloudWatch alarm for ASG healthy host count"
  value       = aws_cloudwatch_metric_alarm.asg_healthy_hosts.arn
}
