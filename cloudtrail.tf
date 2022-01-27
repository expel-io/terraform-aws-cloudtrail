resource "aws_cloudtrail" "cloudtrail" {
  name           = "${var.prefix}-cloudtrail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_bucket.id

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  tags = merge(
    var.tags,
    {}
  )

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]
}

resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket = "${var.prefix}-bucket"
  acl    = "private"

  tags = merge(
    var.tags,
    {}
  )
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_bucket_public_access_block" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
