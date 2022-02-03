resource "aws_cloudtrail" "cloudtrail" {
  name                  = "${var.prefix}-cloudtrail"
  is_multi_region_trail = true
  is_organization_trail = var.enable_organization_trail
  s3_bucket_name        = aws_s3_bucket.cloudtrail_bucket.id

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]

  tags = local.tags
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket_prefix = var.prefix
  acl           = "private"

  dynamic "server_side_encryption_configuration" {
    for_each = var.enable_s3_encryption ? aws_kms_key.cloudtrail_bucket_encryption_key : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = server_side_encryption_configuration.value.arn
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  tags = local.tags
}

resource "aws_kms_key" "cloudtrail_bucket_encryption_key" {
  count = var.enable_s3_encryption ? 1 : 0

  description = "This key is used to encrypt cloudtrail_bucket objects"
  tags        = local.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_public_access_block" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "cloudtrail_bucket_notification" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  queue {
    queue_arn     = aws_sqs_queue.cloudtrail_queue.arn
    events        = ["s3:ObjectCreated:*"]
  }
}
