variable "region" {
  type = string
}

variable "expel_customer_organization_guid" {
  description = "Use your organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench"
  type        = string
}

variable "existing_cloudtrail_bucket_name" {
  description = "Use your AWS CloudTrail S3 Bucket name"
  type        = string
}

variable "aws_mgmt_account_id" {
  description = "Use your AWS management account id"
  type        = string
}

variable "existing_cloudtrail_log_bucket_account_id" {
  description = "Use your AWS cloudtrail log bucket account id"
  type        = string
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

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

provider "aws" {
  region = "us-east-1"
  alias  = "log_bucket"
  assume_role {
    role_arn = "Replace role arn here or create a provider for log bucket account by other means"
  }
}

module "expel_aws_cloudtrail_integration_x_account" {
  source = "../../../"

  providers = {
    aws.log_bucket = aws.log_bucket //setting the log_bucket alias to the log bucket aws provider for existing cloudtrail with resources in different accounts
  }

  is_existing_cloudtrail_cross_account      = true
  expel_customer_organization_guid          = var.expel_customer_organization_guid
  aws_mgmt_account_id                       = var.aws_mgmt_account_id
  existing_cloudtrail_log_bucket_account_id = var.existing_cloudtrail_log_bucket_account_id
  existing_cloudtrail_log_bucket_name       = var.existing_cloudtrail_bucket_name
  existing_cloudtrail_kms_key_arn           = var.existing_cloudtrail_kms_key_arn
  existing_sns_topic_arn                    = var.existing_sns_topic_arn

  prefix = "expel-aws-cloudtrail-x-account"
  tags = {
    "is_external" = "true",
    "x-account"   = "true"
  }
}

output "expel_aws_cloudtrail_integration_x_account" {
  value = module.expel_aws_cloudtrail_integration_x_account
}
