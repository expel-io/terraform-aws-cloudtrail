# Key policies for cloudtrail key
data "aws_iam_policy_document" "cloudtrail_key_policy_document" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${local.customer_aws_account_id}:root",
        data.aws_caller_identity.current.arn
      ]
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

resource "aws_kms_key" "cloudtrail_bucket_encryption_key" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  description         = "This key is used to encrypt cloudtrail bucket."
  enable_key_rotation = var.enable_bucket_encryption_key_rotation
  policy              = data.aws_iam_policy_document.cloudtrail_key_policy_document[0].json
  tags                = local.tags
}

data "aws_iam_policy_document" "notification_key_policy_document" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.is_existing_cloudtrail_cross_account == false ? ["arn:aws:iam::${local.customer_aws_account_id}:root"] : ["arn:aws:iam::${var.existing_cloudtrail_log_bucket_account_id}:root"]
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

resource "aws_kms_key" "notification_encryption_key" {
  provider            = aws.log_bucket
  description         = "This key is used to encrypt SNS topic & SQS queue."
  enable_key_rotation = var.enable_bucket_encryption_key_rotation
  policy              = data.aws_iam_policy_document.notification_key_policy_document.json
  tags                = local.tags
}
