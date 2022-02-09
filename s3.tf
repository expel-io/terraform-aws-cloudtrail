resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket_prefix = var.prefix
  acl           = "private"

  dynamic "server_side_encryption_configuration" {
    for_each = var.enable_cloudtrail_bucket_encryption ? [aws_kms_key.cloudtrail_bucket_encryption_key[0]] : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = server_side_encryption_configuration.value.arn
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  dynamic "logging" {
    for_each = var.enable_bucket_access_logging ? [1] : []
    content {
      target_bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id
    }
  }

  dynamic "versioning" {
    for_each = var.enable_bucket_versioning ? [1] : []
    content {
      enabled = true
    }
  }

  tags = local.tags
}

resource "aws_s3_bucket" "cloudtrail_access_log_bucket" {
  count = var.enable_bucket_access_logging ? 1 : 0

  bucket_prefix = "${var.prefix}-logs"
  acl           = "log-delivery-write"

  dynamic "server_side_encryption_configuration" {
    for_each = var.enable_access_logging_bucket_encryption ? [aws_kms_key.access_logging_bucket_encryption_key[0]] : []

    content {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = server_side_encryption_configuration.value.arn
          sse_algorithm     = "aws:kms"
        }
      }
    }
  }

  dynamic "versioning" {
    for_each = var.enable_bucket_versioning ? [1] : []
    content {
      enabled = true
    }
  }

  tags = local.tags
}

resource "aws_kms_key" "cloudtrail_bucket_encryption_key" {
  count = var.enable_cloudtrail_bucket_encryption ? 1 : 0

  description         = "This key is used to encrypt cloudtrail bucket objects."
  enable_key_rotation = var.enable_bucket_encryption_key_rotation
  tags                = local.tags
}

resource "aws_kms_key" "access_logging_bucket_encryption_key" {
  count = var.enable_access_logging_bucket_encryption ? 1 : 0

  description         = "This key is used to encrypt access logging bucket objects."
  enable_key_rotation = var.enable_bucket_encryption_key_rotation
  tags                = local.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_public_access_block" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_access_log_bucket_public_access_block" {
  count = var.enable_bucket_access_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "cloudtrail_bucket_notification" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  queue {
    queue_arn = aws_sqs_queue.cloudtrail_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
