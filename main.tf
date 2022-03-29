resource "aws_cloudtrail" "cloudtrail" {
  name                  = "${var.prefix}-cloudtrail"
  is_multi_region_trail = true
  is_organization_trail = var.enable_organization_trail
  s3_bucket_name        = aws_s3_bucket.cloudtrail_bucket.id

  enable_log_file_validation = var.enable_cloudtrail_log_file_validation
  kms_key_id                 = aws_kms_key.cloudtrail_bucket_encryption_key.arn

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]

  tags = local.tags
}
