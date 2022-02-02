resource "aws_cloudtrail" "cloudtrail" {
  name           = "${var.prefix}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_bucket.id

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  tags = local.tags

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]
}

// TODO: Encrypt data
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket_prefix = var.prefix
  acl           = "private"

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_public_access_block" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
