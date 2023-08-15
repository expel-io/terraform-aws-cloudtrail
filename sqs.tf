resource "aws_sqs_queue" "cloudtrail_queue" {
  provider                  = aws.log_bucket
  name                      = "${var.prefix}-queue"
  message_retention_seconds = var.queue_message_retention_days * 24 * 60 * 60
  kms_master_key_id         = aws_kms_key.notification_encryption_key.arn

  tags = local.tags
}

resource "aws_sqs_queue_policy" "sqs_bucket_policy" {
  provider  = aws.log_bucket
  queue_url = aws_sqs_queue.cloudtrail_queue.id
  policy    = data.aws_iam_policy_document.sns_queue_iam_document.json
}

data "aws_iam_policy_document" "sns_queue_iam_document" {
  # Allow SNS to send messages to Queue
  statement {
    actions   = ["sqs:SendMessage", "sqs:SendMessageBatch"]
    resources = [aws_sqs_queue.cloudtrail_queue.arn]
    effect    = "Allow"
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_sns_topic_arn]
    }
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic_subscription" "cloudtrail_sns_topic_subscription" {
  provider  = aws.log_bucket
  topic_arn = local.cloudtrail_sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cloudtrail_queue.arn
}
