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
  region = var.region
}

module "expel_aws_cloudtrail_integration" {
  source = "../../../"

  providers = {
    aws.log_bucket = aws //setting the log_bucket alias to default aws provider for existing cloudtrail with resources in single account
  }

  expel_customer_organization_guid = var.expel_customer_organization_guid
  existing_cloudtrail_bucket_name  = var.existing_cloudtrail_bucket_name
  existing_cloudtrail_kms_key_arn  = var.existing_cloudtrail_kms_key_arn
  existing_sns_topic_arn           = var.existing_sns_topic_arn

  tags = {
    "is_external" = "true"
  }
}

output "expel_aws_cloudtrail_integration" {
  value = module.expel_aws_cloudtrail_integration
}
