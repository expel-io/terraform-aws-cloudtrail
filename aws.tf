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

  customer_aws_account_id      = coalesce(var.expel_customer_aws_account_id, data.aws_caller_identity.current.account_id)
  region                       = data.aws_region.current.name
  customer_aws_organization_id = try(data.aws_organizations_organization.current[0].roots[0].id, "")

  cloudtrail_bucket_arn                = var.existing_cloudtrail_bucket_name != null ? "arn:aws:s3:::${var.existing_cloudtrail_bucket_name}" : "arn:aws:s3:::${var.prefix}-${random_uuid.cloudtrail_bucket_name[0].result}"
  cloudtrail_bucket_name               = var.existing_cloudtrail_bucket_name != null ? var.existing_cloudtrail_bucket_name : "${var.prefix}-${random_uuid.cloudtrail_bucket_name[0].result}"
  cloudtrail_bucket_encryption_key_arn = var.existing_cloudtrail_bucket_name != null ? var.existing_cloudtrail_kms_key_arn : aws_kms_key.cloudtrail_bucket_encryption_key[0].arn

  cloudtrail_sns_topic_arn = var.existing_sns_topic_arn == null ? "arn:aws:sns:${local.region}:${local.customer_aws_account_id}:${var.prefix}-${random_uuid.cloudtrail_sns_topic_name[0].result}" : var.existing_sns_topic_arn
}
