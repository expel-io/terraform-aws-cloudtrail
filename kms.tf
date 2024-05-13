locals {
  provisioner_role_arn         = var.assume_role_arn == null ? data.aws_iam_session_context.current_source_role.issuer_arn : var.assume_role_arn
  cloudtrail_key_policy_root   = "arn:aws:iam::${local.customer_aws_account_id}:root" #only used for new cloudtrails
  notification_key_policy_root = var.is_existing_cloudtrail_cross_account == false ? "arn:aws:iam::${local.customer_aws_account_id}:root" : "arn:aws:iam::${var.existing_cloudtrail_log_bucket_account_id}:root"
}

# This data block defines the IAM policy document for the KMS key used by CloudTrail.
# The policy allows the root user of the customer's AWS account and the current caller to perform all KMS actions.
# It also allows the CloudTrail service to generate data keys for encrypting logs and to describe the KMS key.
# Additionally, it allows the S3 service to generate data keys and decrypt them for encrypting and decrypting logs in the CloudTrail bucket.
data "aws_iam_policy_document" "cloudtrail_key_policy_document" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.cloudtrail_key_policy_root, local.provisioner_role_arn]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.customer_aws_account_id}:trail/*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.region}:${local.customer_aws_account_id}:trail/${var.prefix}-trail"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.region}:${local.customer_aws_account_id}:trail/${var.prefix}-trail"]
    }
  }

  statement {
    sid    = "Allow CloudTrail bucket to encrypt/decrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_bucket_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.customer_aws_account_id]
    }
  }
}

# This resource creates a KMS key using the policy defined in cloudtrail_key_policy_document.
# The key is used to encrypt the CloudTrail bucket.
resource "aws_kms_key" "cloudtrail_bucket_encryption_key" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  description         = "This key is used to encrypt cloudtrail bucket."
  enable_key_rotation = var.enable_bucket_encryption_key_rotation
  policy              = data.aws_iam_policy_document.cloudtrail_key_policy_document[0].json
  tags                = local.tags
}

# This data block defines the IAM policy document for the KMS key used by notifications.
# The policy allows the root user of the customer's AWS account or the account that owns the existing CloudTrail log bucket to perform all KMS actions.
# It also allows the S3 service to generate data keys and decrypt them for encrypting and decrypting logs in the CloudTrail bucket.
# Additionally, it allows the SNS service to generate data keys and decrypt them for encrypting and decrypting notifications.
data "aws_iam_policy_document" "notification_key_policy_document" {
  count = var.existing_notification_kms_key_arn == null ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.notification_key_policy_root, local.provisioner_role_arn]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail bucket to encrypt/decrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey", "kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_bucket_arn]
    }
  }

  statement {
    sid    = "Allow SNS service to encrypt/decrypt"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_sns_topic_arn]
    }
  }
}

# This resource creates a KMS key using the policy defined in notification_key_policy_document.
# The key is used to encrypt SNS topics and SQS queues.
resource "aws_kms_key" "notification_encryption_key" {
  count               = var.existing_notification_kms_key_arn == null ? 1 : 0
  provider            = aws.log_bucket
  description         = "This key is used to encrypt SNS topic & SQS queue."
  enable_key_rotation = var.enable_bucket_encryption_key_rotation
  policy              = data.aws_iam_policy_document.notification_key_policy_document[0].json
  tags                = local.tags
}
