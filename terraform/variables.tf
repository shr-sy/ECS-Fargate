# ------------------------
# General Variables
# ------------------------
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name for all resources"
  type        = string
  default     = "efp"
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  default     = "dev"
}

# ------------------------
# GitHub Variables
# ------------------------
variable "github_owner" {
  description = "GitHub organization or username"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch to trigger CodePipeline"
  type        = string
  default     = "main"
}

variable "github_oauth_token" {
  description = "GitHub personal access token for CodePipeline authentication"
  type        = string
  sensitive   = true
}

# ------------------------
# Networking (VPC/Subnets)
# ------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

# ------------------------
# ECS / Fargate Variables
# ------------------------
variable "container_port" {
  description = "Application port exposed by the container"
  type        = number
  default     = 3000
}

variable "cpu" {
  description = "Fargate task CPU"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate task memory"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of ECS task replicas"
  type        = number
  default     = 1
}

# ------------------------
# CodeBuild Variables
# ------------------------
variable "codebuild_compute_type" {
  description = "CodeBuild compute size"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codebuild_image" {
  description = "CodeBuild environment image"
  type        = string
  default     = "aws/codebuild/standard:7.0"
}
