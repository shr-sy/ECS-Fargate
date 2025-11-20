terraform {
  required_version = ">= 1.5.0"

  cloud {
    organization = "YOUR_HCP_ORG"

    workspaces {
      name = "ecs-fargate-deploy"
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
  region = var.aws_region
}
