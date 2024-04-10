# Creates an AWS SQS queue for CloudTrail logs.
resource "aws_sqs_queue" "cloudtrail_queue" {
  provider                  = aws.log_bucket
  name                      = "${var.prefix}-queue"
  message_retention_seconds = var.queue_message_retention_days * 24 * 60 * 60
  kms_master_key_id         = local.notification_encryption_key_arn

  tags = local.tags
}

# Attaches a policy to the SQS queue to allow SNS to send messages to it.
resource "aws_sqs_queue_policy" "sqs_bucket_policy" {
  provider  = aws.log_bucket
  queue_url = aws_sqs_queue.cloudtrail_queue.id
  policy    = data.aws_iam_policy_document.sns_queue_iam_document.json
}

# Defines an IAM policy document that allows SNS to send messages to the SQS queue.
data "aws_iam_policy_document" "sns_queue_iam_document" {
  # Allow SNS to send messages to Queue
  statement {
    # Specifies the actions that SNS can perform on the SQS queue.
    actions   = ["sqs:SendMessage", "sqs:SendMessageBatch"]
    resources = [aws_sqs_queue.cloudtrail_queue.arn]
    effect    = "Allow"

    condition {
      # Specifies that the source ARN must match the CloudTrail SNS topic ARN.
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.cloudtrail_sns_topic_arn]
    }

    principals {
      # Specifies that the principal is the SNS service.
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
  }
}

# Subscribes the SQS queue to the CloudTrail SNS topic.
resource "aws_sns_topic_subscription" "cloudtrail_sns_topic_subscription" {
  provider  = aws.log_bucket
  topic_arn = local.cloudtrail_sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cloudtrail_queue.arn
}
