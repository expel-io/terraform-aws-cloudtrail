# Key policies for cloudtrail key
data "aws_iam_policy_document" "cloudtrail_key_policy_document" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.customer_aws_account_id}:root"]
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
      values   = ["arn:aws:cloudtrail:${local.region}:${local.customer_aws_account_id}:trail/${var.prefix}-cloudtrail"]
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
      values   = ["arn:aws:cloudtrail:${local.region}:${local.customer_aws_account_id}:trail/${var.prefix}-cloudtrail"]
    }
  }

  statement {
    sid    = "Allow cloudtrail bucket to encrypt/decrypt SQS queue"
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
      values   = ["arn:aws:s3:::${var.prefix}-${random_uuid.cloudtrail_bucket_name.result}"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = ["${local.customer_aws_account_id}"]
    }
  }
}

resource "aws_kms_key" "cloudtrail_bucket_encryption_key" {
  description         = "This key is used to encrypt cloudtrail bucket & SQS queue."
  enable_key_rotation = var.enable_bucket_encryption_key_rotation
  policy              = data.aws_iam_policy_document.cloudtrail_key_policy_document.json
  tags                = local.tags
}

