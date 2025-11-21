############################
# AWS / GitHub Credentials
############################
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "github_branch" {
  type        = string
  description = "GitHub branch to build"
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
  type      = string
  sensitive = true
}

############################
# Project / ECS variables
############################
variable "project_name" {
  type        = string
  description = "Project name"
  default     = "ecs-fargate-project"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "container_port" {
  type        = number
  description = "Container port"
  default     = 3000
}

variable "cpu" {
  type        = number
  description = "ECS task CPU"
  default     = 256
}

variable "memory" {
  type        = number
  description = "ECS task memory"
  default     = 512
}
