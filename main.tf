# ignoring since cloudtrail is inaccessable beyond integration with S3 which uses encryption by default
# tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption
resource "aws_cloudtrail" "cloudtrail" {
  name                  = "${var.prefix}-cloudtrail"
  is_multi_region_trail = true
  is_organization_trail = var.enable_organization_trail
  s3_bucket_name        = aws_s3_bucket.cloudtrail_bucket.id

  enable_log_file_validation = var.enable_cloudtrail_log_file_validation

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]

  tags = local.tags
}
