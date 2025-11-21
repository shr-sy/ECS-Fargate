terraform {
  required_version = ">= 1.5"

  cloud {
    organization = "your-hcp-org"
    workspaces {
      name = "ecs-fargate-ws"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}
