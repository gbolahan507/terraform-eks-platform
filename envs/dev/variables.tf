variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "aws_profile" {
  description = "Local AWS CLI profile name used for authentication"
  type        = string
  default     = "hameed-admin"
}

variable "environment" {
  description = "Environment name (used in tags and resource names)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Short project identifier used in resource names"
  type        = string
  default     = "eks-platform"
}