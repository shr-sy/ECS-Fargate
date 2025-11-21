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
  region = "us-east-1"
}

provider "github" {
  token = var.github_oauth_token
  owner = var.github_owner
}
