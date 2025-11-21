############################
# AWS / GitHub Variables
############################
variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch"
}

variable "github_owner" {
  type        = string
  description = "GitHub owner/org"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name"
}

variable "github_oauth_token" {
  type      = string
  sensitive = true
}

############################
# Project Variables
############################
variable "project_name" {
  type    = string
  default = "ecs-fargate-project"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "container_port" {
  type    = number
  default = 3000
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}
