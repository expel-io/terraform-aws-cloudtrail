resource "random_uuid" "cloudtrail_bucket_name" {
}

# temporarily ignoring because tfsec does not yet support AWS v4 configuration
# tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "${var.prefix}-${random_uuid.cloudtrail_bucket_name.result}"

  depends_on = [aws_sqs_queue.cloudtrail_queue]

  tags = local.tags
}

resource "aws_s3_bucket_acl" "cloudtrail_bucket_acl" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "cloudtrail_bucket_versioning" {
  count = var.enable_bucket_versioning ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.cloudtrail_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_bucket_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "cloudtrail_bucket_logging" {
  count = var.enable_bucket_access_logging ? 1 : 0

  bucket        = aws_s3_bucket.cloudtrail_bucket.id
  target_bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id

  target_prefix = "log/"
}

# temporarily ignoring because tfsec does not yet support AWS v4 configuration
# tfsec:ignore:aws-s3-enable-bucket-encryption tfsec:ignore:aws-s3-encryption-customer-key tfsec:ignore:aws-s3-enable-bucket-logging tfsec:ignore:aws-s3-enable-versioning
resource "aws_s3_bucket" "cloudtrail_access_log_bucket" {
  count = var.enable_bucket_access_logging ? 1 : 0

  bucket = "${var.prefix}-logs-${random_uuid.cloudtrail_bucket_name.result}"

  tags = local.tags
}

resource "aws_s3_bucket_acl" "cloudtrail_access_log_bucket_acl" {
  count = var.enable_bucket_access_logging ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "cloudtrail_access_log_bucket_versioning" {
  count = var.enable_bucket_versioning ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_access_log_bucket_server_side_encryption_configuration" {
  count  = var.enable_access_logging_bucket_encryption ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail_access_log_bucket[0].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.cloudtrail_bucket_encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
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
