# This Terraform configuration file sets up an integration between Expel and an existing AWS CloudTrail in a cross-account scenario.


# variables:
# - region: The AWS region where the CloudTrail setup exists.
# - expel_customer_organization_guid: The organization GUID assigned by Expel.
# - existing_cloudtrail_bucket_name: The name of the AWS CloudTrail S3 bucket.
# - aws_management_account_id: The AWS management account ID.
# - existing_cloudtrail_log_bucket_account_id: The account ID of the AWS CloudTrail log bucket.
# - existing_cloudtrail_kms_key_arn: The ARN of the AWS KMS Key used for the CloudTrail infrastructure.
# - existing_sns_topic_arn: The ARN of the AWS CloudTrail SNS topic.

# Define input variables
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

variable "aws_management_account_id" {
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

# Define AWS provider configuration
# This defines the AWS provider configuration for the existing-cloudtrail example in the terraform-aws-cloudtrail module.
# It sets the region to "us-east-1" and uses the "default" profile for authentication.
provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Define an additional AWS provider configuration with an alias "log_bucket" for the log bucket account.
# This provider assumes a role specified by the "role_arn" attribute.
# Replace the "role_arn" value with the actual role ARN or create a provider for the log bucket account by other means.
provider "aws" {
  region = "us-east-1"
  alias  = "log_bucket"
  assume_role {
    role_arn = "Replace role arn here or create a provider for log bucket account by other means"
  }
}

# Define module for Expel AWS CloudTrail integration in cross-account scenario
# This sets up an existing CloudTrail with resources in different accounts.
# It uses an existing CloudTrail log bucket and sets up the necessary configurations for cross-account access.
module "expel_aws_cloudtrail_integration_x_account" {
  source = "../../../"

  # Providers
  # The `aws.log_bucket` provider is set as an alias to the log bucket AWS provider for the existing CloudTrail.
  providers = {
    aws.log_bucket = aws.log_bucket
  }

  # Configuration Variables
  # - `is_existing_cloudtrail_cross_account`: A boolean variable indicating whether this is an existing CloudTrail with resources in different accounts.
  # - `expel_customer_organization_guid`: The organization GUID for the customer.
  # - `aws_management_account_id`: The AWS management account ID.
  # - `existing_cloudtrail_log_bucket_account_id`: The account ID of the existing CloudTrail log bucket.
  # - `existing_cloudtrail_bucket_name`: The name of the existing CloudTrail bucket.
  # - `existing_cloudtrail_kms_key_arn`: The ARN of the existing CloudTrail KMS key.
  # - `existing_sns_topic_arn`: The ARN of the existing SNS topic.

  is_existing_cloudtrail_cross_account      = true
  expel_customer_organization_guid          = var.expel_customer_organization_guid
  aws_management_account_id                 = var.aws_management_account_id
  existing_cloudtrail_log_bucket_account_id = var.existing_cloudtrail_log_bucket_account_id
  existing_cloudtrail_bucket_name           = var.existing_cloudtrail_bucket_name
  existing_cloudtrail_kms_key_arn           = var.existing_cloudtrail_kms_key_arn
  existing_sns_topic_arn                    = var.existing_sns_topic_arn

  # Prefix and Tags
  # - `prefix`: The prefix to be added to the CloudTrail resources.
  # - `tags`: Additional tags to be added to the CloudTrail resources.
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
