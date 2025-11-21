##############################
# Project Settings
##############################

variable "project_name" {
  type        = string
  description = "Name of the project"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

##############################
# Network
##############################

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

##############################
# ECS / Container
##############################

variable "container_port" {
  type        = number
  description = "Container port for ECS Fargate"
}

variable "cpu" {
  type        = number
  description = "ECS Fargate Task CPU"
}

variable "memory" {
  type        = number
  description = "ECS Fargate Task Memory"
}

##############################
# GitHub Settings
##############################

variable "github_owner" {
  type        = string
  description = "GitHub username or org name"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "github_branch" {
  type        = string
  description = "Branch to use for CodeBuild"
  default     = "main"
}

variable "github_oauth_token" {
  type        = string
  sensitive   = true
  description = "GitHub personal access token for CodeBuild OAuth"
}

##############################
# Optional (if needed later)
##############################

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment tag"
}
