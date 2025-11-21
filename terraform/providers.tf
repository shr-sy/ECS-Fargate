terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.69, < 7.0"  # Allow AWS 6.x for latest modules
    }
  }

  backend "remote" {
    organization = "YOUR_HCP_ORG"

    workspaces {
      name = "YOUR_WORKSPACE"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
