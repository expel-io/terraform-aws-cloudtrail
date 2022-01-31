terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.71.0"
    }
  }
  required_version = ">= 1.1.0"
}

data "aws_region" "current" {}