############################################################
# TERRAFORM & PROVIDERS
############################################################
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.69"  # Pin to latest stable 5.x version
    }
  }

  backend "remote" {
    organization = "YOUR_HCP_ORG"

    workspaces {
      name = "YOUR_WORKSPACE"
    }
  }
}

############################################################
# AWS PROVIDER
############################################################
provider "aws" {
  region = var.aws_region
}

############################################################
# OPTIONAL: Pin all modules to use this provider
# Ensures no conflicts with module constraints
############################################################
provider "aws" {
  alias  = "default"
  region = var.aws_region
}
