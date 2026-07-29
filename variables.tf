variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

#variable "vpc_name" {
#  description = "VPC name"
#  type        = string
#}

variable "my_ip" {
  description = "Admin IP"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "key_pair" {
  description = "private key"
  type        = string
  sensitive   = true
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 6
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}

variable "certificate_arn" {
  description = "ARN of an ACM certificate for HTTPS listener. If null, HTTP-only."
  type        = string
  default     = null
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention in days for VPC Flow Logs"
  type        = number
  default     = 30
}

variable "alarm_arn" {
  description = "ARN of an SNS topic for CloudWatch alarm notifications. If null, no notifications."
  type        = string
  default     = null
}