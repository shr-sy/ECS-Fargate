############################
# AWS / GitHub Variables
############################
variable "aws_region" {
  type        = string
  description = "AWS region for all resources"
  default     = "us-east-1"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch to build"
  default     = "main"
}

variable "github_owner" {
  type        = string
  description = "GitHub repository owner"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_oauth_token" {
  type        = string
  sensitive   = true
  description = "GitHub token for source integration"
}

############################
# Project Variables
############################
variable "project_name" {
  type        = string
  default     = "ecs-fargate-project"
  description = "Base project name used in AWS resources"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for VPC"
}

variable "container_port" {
  type        = number
  default     = 3000
  description = "Container port exposed by the application"
}

variable "cpu" {
  type        = number
  default     = 256
  description = "ECS task CPU"
}

variable "memory" {
  type        = number
  default     = 512
  description = "ECS task Memory"
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "Number of ECS tasks to run"
}
