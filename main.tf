# ignoring to maintain parity with other cloudtrail onboarding methods
# tfsec:ignore:aws-cloudtrail-ensure-cloudwatch-integration
resource "aws_cloudtrail" "cloudtrail" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  name                  = "${var.prefix}-trail"
  is_multi_region_trail = true
  is_organization_trail = var.enable_organization_trail
  s3_bucket_name        = aws_s3_bucket.cloudtrail_bucket[0].id

  enable_log_file_validation = var.enable_cloudtrail_log_file_validation
  kms_key_id                 = aws_kms_key.cloudtrail_bucket_encryption_key[0].arn

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy[0]]

  tags = local.tags
}
