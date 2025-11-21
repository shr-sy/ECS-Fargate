terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.69"  # Stable 5.x version
    }
  }
}

provider "aws" {
  region = var.aws_region
}
