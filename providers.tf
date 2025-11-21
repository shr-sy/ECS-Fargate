terraform {
  required_version = ">= 1.3.0"

  cloud {
    organization = "YOUR_HCP_ORG"
    workspaces {
      name = "YOUR_WORKSPACE"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "github" {
  token = var.github_oauth_token
  owner = var.github_owner
}
