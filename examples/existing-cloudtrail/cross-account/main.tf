# This Terraform configuration file sets up an integration between Expel and an existing AWS CloudTrail in a cross-account scenario.


# Define input Variables
variable "region" {
  type = string
}

variable "expel_customer_organization_guid" {
  type = string
}

variable "existing_cloudtrail_bucket_name" {
  type = string
}

variable "aws_management_account_id" {
  type = string
}

variable "existing_cloudtrail_log_bucket_account_id" {
  type = string
}

variable "existing_cloudtrail_kms_key_arn" {
  type    = string
  default = null
}

variable "existing_sns_topic_arn" {
  type    = string
  default = null
}

# AWS provider
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# AWS provider for log bucket account
provider "aws" {
  region = "us-east-1"
  alias  = "log_bucket"
  assume_role {
    role_arn = "Replace role arn here or create a provider for log bucket account by other means"
  }
}

# Expel AWS CloudTrail module
module "expel_aws_cloudtrail_integration_x_account" {
  source = "../../../"

  providers = {
    aws.log_bucket = aws.log_bucket
  }

  is_existing_cloudtrail_cross_account      = true
  expel_customer_organization_guid          = var.expel_customer_organization_guid
  aws_management_account_id                 = var.aws_management_account_id
  existing_cloudtrail_log_bucket_account_id = var.existing_cloudtrail_log_bucket_account_id
  existing_cloudtrail_bucket_name           = var.existing_cloudtrail_bucket_name
  existing_cloudtrail_kms_key_arn           = var.existing_cloudtrail_kms_key_arn
  existing_sns_topic_arn                    = var.existing_sns_topic_arn
  prefix = "expel-aws-cloudtrail"

  tags = {
    "is_external" = "true",
    "x-account"   = "true"
  }
}

# Define output for Expel AWS CloudTrail integration in cross-account scenario
output "expel_aws_cloudtrail_integration_x_account" {
  value = module.expel_aws_cloudtrail_integration_x_account
}