resource "random_uuid" "cloudtrail_sns_topic_name" {
  count = var.existing_sns_topic_arn == null ? 1 : 0
}

resource "aws_sns_topic" "cloudtrail_sns_topic" {
  provider = aws.log_bucket
  count    = var.existing_sns_topic_arn == null ? 1 : 0

  name              = "${var.prefix}-${random_uuid.cloudtrail_sns_topic_name[0].result}"
  display_name      = "CloudTrail SNS Topic"
  kms_master_key_id = aws_kms_key.notification_encryption_key.arn
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  provider = aws.log_bucket
  count    = var.existing_sns_topic_arn == null ? 1 : 0

  arn    = aws_sns_topic.cloudtrail_sns_topic[0].arn
  policy = data.aws_iam_policy_document.sns_topic_iam_document[0].json
}

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
