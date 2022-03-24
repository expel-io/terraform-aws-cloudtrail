# ignoring because SSE encryption is enabled by default
# tfsec:ignore:aws-sqs-enable-queue-encryption
resource "aws_sqs_queue" "cloudtrail_queue" {
  name                      = "${var.prefix}-queue"
  message_retention_seconds = var.queue_message_retention_days * 24 * 60 * 60
  kms_master_key_id         = aws_kms_key.cloudtrail_bucket_encryption_key.arn

  tags = local.tags
}
