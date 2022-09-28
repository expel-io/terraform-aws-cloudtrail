resource "aws_sqs_queue" "cloudtrail_queue" {
  name                      = "${var.prefix}-queue"
  message_retention_seconds = var.queue_message_retention_days * 24 * 60 * 60
  kms_master_key_id         = aws_kms_key.notification_encryption_key.arn

  tags = local.tags
}

resource "aws_sns_topic_subscription" "cloudtrail_sns_topic_subscription" {
  topic_arn = local.cloudtrail_sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.cloudtrail_queue.arn
}
