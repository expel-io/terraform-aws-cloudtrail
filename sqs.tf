resource "aws_sqs_queue" "cloudtrail_queue" {
  name                      = "${var.prefix}-queue"
  message_retention_seconds = var.queue_message_retention_days * 24 * 60 * 60
  sqs_managed_sse_enabled   = var.enable_sqs_encryption

  tags = local.tags
}
