# This Terraform file defines resources related to an SNS topic for CloudTrail.

# The `random_uuid` resource generates a random UUID for the CloudTrail SNS topic name.
resource "random_uuid" "cloudtrail_sns_topic_name" {
  count = var.existing_sns_topic_arn == null ? 1 : 0
}

# The `aws_sns_topic` resource creates an SNS topic for CloudTrail.
resource "aws_sns_topic" "cloudtrail_sns_topic" {
  provider = aws.log_bucket
  count    = var.existing_sns_topic_arn == null ? 1 : 0

  name              = "${var.prefix}-${random_uuid.cloudtrail_sns_topic_name[0].result}"
  display_name      = "CloudTrail SNS Topic"
  kms_master_key_id = local.notification_encryption_key_arn
}

# The `aws_sns_topic_policy` resource defines the policy for the CloudTrail SNS topic.
resource "aws_sns_topic_policy" "sns_topic_policy" {
  provider = aws.log_bucket
  count    = var.existing_sns_topic_arn == null ? 1 : 0

  arn    = aws_sns_topic.cloudtrail_sns_topic[0].arn
  policy = data.aws_iam_policy_document.sns_topic_iam_document[0].json
}

# The `data.aws_iam_policy_document` data source defines the IAM policy document for the CloudTrail SNS topic.
data "aws_iam_policy_document" "sns_topic_iam_document" {
  count = var.existing_sns_topic_arn == null ? 1 : 0

  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.cloudtrail_sns_topic[0].arn]
    effect    = "Allow"

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_bucket_arn]
    }

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}
