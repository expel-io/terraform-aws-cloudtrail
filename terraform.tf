terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.71.0"
    }
  }
  required_version = ">= 1.1.0"
}

locals {
  default_tags = {
    "vendor" = "expel"
  }

  tags = merge(
    var.tags,
    local.default_tags,
  )
}

data "aws_region" "current" {}
