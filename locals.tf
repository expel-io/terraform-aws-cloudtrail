data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "current" {
  count = var.enable_organization_trail ? 1 : 0
}

locals {
  default_tags = {
    "vendor" = "expel"
  }

  tags = merge(
    var.tags,
    local.default_tags,
  )

  customer_aws_account_id     = coalesce(var.expel_customer_aws_account_id, data.aws_caller_identity.current.account_id)
  region                      = data.aws_region.current.name
  stackset_organization_units = var.stackset_target_organizational_units != null ? var.stackset_target_organizational_units : [try(data.aws_organizations_organization.current[0].roots[0].id, "")]

  cloudtrail_bucket_arn                = var.existing_cloudtrail_bucket_name != null ? "arn:aws:s3:::${var.existing_cloudtrail_bucket_name}" : "arn:aws:s3:::${var.prefix}-${random_uuid.cloudtrail_bucket_name[0].result}"
  cloudtrail_bucket_name               = var.existing_cloudtrail_bucket_name != null ? var.existing_cloudtrail_bucket_name : "${var.prefix}-${random_uuid.cloudtrail_bucket_name[0].result}"
  cloudtrail_bucket_encryption_key_arn = var.existing_cloudtrail_bucket_name != null ? var.existing_cloudtrail_kms_key_arn : aws_kms_key.cloudtrail_bucket_encryption_key[0].arn

  sns_account_id           = var.is_existing_cloudtrail_cross_account == false ? local.customer_aws_account_id : var.existing_cloudtrail_log_bucket_account_id
  cloudtrail_sns_topic_arn = var.existing_sns_topic_arn == null ? "arn:aws:sns:${local.region}:${local.sns_account_id}:${var.prefix}-${random_uuid.cloudtrail_sns_topic_name[0].result}" : var.existing_sns_topic_arn

  create_stackset = (var.is_existing_cloudtrail_cross_account == true || var.enable_organization_trail == true) ? true : false
  # throw a runtime error if `is_existing_cloudtrail_cross_account` is set to `true` but other required variables are missing
  # tflint-ignore: terraform_unused_declarations
  validate_is_existing_cloudtrail_cross_account = (var.is_existing_cloudtrail_cross_account == true && (var.existing_cloudtrail_bucket_name == null || var.aws_management_account_id == null || var.existing_cloudtrail_log_bucket_account_id == null)) ? tobool("For existing cloudtrail with cross account resources, please pass in the log bucket name, log bucket account id & management account id") : true
}
