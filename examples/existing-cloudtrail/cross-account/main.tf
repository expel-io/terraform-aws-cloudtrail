# This Terraform configuration file sets up an integration between Expel and an
# existing AWS CloudTrail in a cross-account scenario.


# Define input Variables
variable "region" {
  type = string
}

variable "expel_customer_organization_guid" {
  description = "Use your organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench"
  type = string
}

variable "existing_cloudtrail_bucket_name" {
  description = "Use your AWS CloudTrail S3 Bucket name"
  type        = string
}

variable "aws_management_account_id" {
  description = "Use your AWS management account id"
  type        = string
}

variable "existing_cloudtrail_log_bucket_account_id" {
  description = "Use your AWS cloudtrail log bucket account id"
  type = string
}

variable "existing_cloudtrail_kms_key_arn" {
  description = "Use your AWS KMS Key ARN that is used for your CloudTrail infrastructure"
  type        = string
  default     = null
}

variable "existing_sns_topic_arn" {
  description = "Use your AWS CloudTrail SNS Topic ARN"
  type        = string
  default     = null
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
