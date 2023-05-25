resource "random_uuid" "cloudtrail_bucket_name" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  bucket = "${var.prefix}-${random_uuid.cloudtrail_bucket_name[0].result}"

  depends_on = [aws_sqs_queue.cloudtrail_queue]

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "cloudtrail_bucket_versioning" {
  count = var.existing_cloudtrail_bucket_name == null && var.enable_bucket_versioning ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_bucket_server_side_encryption_configuration" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_bucket_encryption_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_bucket_logging" {
  count = var.existing_cloudtrail_bucket_name == null && var.enable_bucket_access_logging ? 1 : 0

  bucket        = aws_s3_bucket.cloudtrail_bucket[0].id
  target_bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id

  target_prefix = "log/"
}

resource "aws_s3_bucket" "cloudtrail_access_log_bucket" {
  count = var.existing_cloudtrail_bucket_name == null && var.enable_bucket_access_logging ? 1 : 0

  bucket = "${var.prefix}-logs-${random_uuid.cloudtrail_bucket_name[0].result}"

  tags = local.tags
}

resource "aws_s3_bucket_policy" "cloudtrail_access_log_bucket_policy" {
  count = var.existing_cloudtrail_bucket_name == null && var.enable_bucket_access_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LogDeliveryPermissions",
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Action = ["s3:PutObject", "s3:GetBucketAcl"],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.cloudtrail_access_log_bucket[0].id}/*",
          "arn:aws:s3:::${aws_s3_bucket.cloudtrail_access_log_bucket[0].id}",
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "cloudtrail_access_log_bucket_versioning" {
  count = var.existing_cloudtrail_bucket_name == null && var.enable_bucket_versioning ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_access_log_bucket_server_side_encryption_configuration" {
  count  = var.existing_cloudtrail_bucket_name == null && var.enable_access_logging_bucket_encryption ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_bucket_encryption_key[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_public_access_block" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_access_log_bucket_public_access_block" {
  count = var.existing_cloudtrail_bucket_name == null && var.enable_bucket_access_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "cloudtrail_bucket_notification" {
  count = var.existing_sns_topic_arn == null ? 1 : 0

  bucket = var.existing_cloudtrail_bucket_name == null ? aws_s3_bucket.cloudtrail_bucket[0].id : var.existing_cloudtrail_bucket_name

  topic {
    topic_arn = aws_sns_topic.cloudtrail_sns_topic[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}
