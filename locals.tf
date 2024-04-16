#  This Terraform file defines the local variables used in the AWS CloudTrail module.
#  Note: This file is part of the terraform-aws-cloudtrail module.

data "aws_region" "current" {}

# Fetch the current AWS caller identity
data "aws_caller_identity" "current" {}

# Fetch the current AWS organization if organization trail is enabled
data "aws_organizations_organization" "current" {
  count = var.enable_organization_trail ? 1 : 0
}

# Define local values
locals {
  # Default tags to be applied to resources
  default_tags = {
    "vendor" = "expel"
  }
  # Merge default tags with user-defined tags
  tags = merge(
    var.tags,
    local.default_tags,
  )
  # Determine the customer AWS account ID
  customer_aws_account_id     = coalesce(var.expel_customer_aws_account_id, data.aws_caller_identity.current.account_id)
  # Fetch the current AWS region name
  region                      = data.aws_region.current.name
  # Determine the organizational units for the stackset
  stackset_organization_units = var.stackset_target_organizational_units != null ? var.stackset_target_organizational_units : [try(data.aws_organizations_organization.current[0].roots[0].id, "")]
  # Determine the ARN, name, and encryption key ARN for the CloudTrail bucket
  cloudtrail_bucket_arn                = var.existing_cloudtrail_bucket_name != null ? "arn:aws:s3:::${var.existing_cloudtrail_bucket_name}" : "arn:aws:s3:::${var.prefix}-${random_uuid.cloudtrail_bucket_name[0].result}"
  cloudtrail_bucket_name               = var.existing_cloudtrail_bucket_name != null ? var.existing_cloudtrail_bucket_name : "${var.prefix}-${random_uuid.cloudtrail_bucket_name[0].result}"
  cloudtrail_bucket_encryption_key_arn = var.existing_cloudtrail_bucket_name != null ? var.existing_cloudtrail_kms_key_arn : aws_kms_key.cloudtrail_bucket_encryption_key[0].arn
  # Determine the encryption key ARN for notifications
  notification_encryption_key_arn      = var.existing_notification_kms_key_arn != null ? var.existing_notification_kms_key_arn : aws_kms_key.notification_encryption_key[0].arn
  # Determine the account ID and ARN for the SNS topic
  sns_account_id           = var.is_existing_cloudtrail_cross_account == false ? local.customer_aws_account_id : var.existing_cloudtrail_log_bucket_account_id
  cloudtrail_sns_topic_arn = var.existing_sns_topic_arn == null ? "arn:aws:sns:${local.region}:${local.sns_account_id}:${var.prefix}-${random_uuid.cloudtrail_sns_topic_name[0].result}" : var.existing_sns_topic_arn
  # Determine whether to create a stackset
  create_stackset = (var.is_existing_cloudtrail_cross_account == true || var.enable_organization_trail == true) ? true : false
  # throw a runtime error if `is_existing_cloudtrail_cross_account` is set to `true` but other required variables are missing
  # tflint-ignore: terraform_unused_declarations
  validate_is_existing_cloudtrail_cross_account = (var.is_existing_cloudtrail_cross_account == true && (var.existing_cloudtrail_bucket_name == null || var.aws_management_account_id == null || var.existing_cloudtrail_log_bucket_account_id == null)) ? tobool("For existing cloudtrail with cross account resources, please pass in the log bucket name, log bucket account id & management account id") : true
}
