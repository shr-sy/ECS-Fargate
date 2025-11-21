variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  sensitive   = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  sensitive   = true
}

variable "github_branch" {
  type        = string
}

variable "github_owner" {
  type        = string
}

variable "github_repo" {
  type        = string
}

variable "github_oauth_token" {
  type        = string
  sensitive   = true
}

variable "project_name" {
  type        = string
  default     = "ecs-fargate-project"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_port" {
  type        = number
  default     = 3000
}

variable "cpu" {
  type        = number
  default     = 256
}

variable "memory" {
  type        = number
  default     = 512
}
