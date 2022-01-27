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
