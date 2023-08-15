output "role_arn" {
  description = "IAM Role ARN of the role for Expel to assume to access CloudTrail data"
  value       = var.is_existing_cloudtrail_cross_account ? "arn:aws:iam::${var.existing_cloudtrail_log_bucket_account_id}:role/${var.expel_assume_role_name}" : aws_iam_role.mgmt_expel_assume_role.arn
}

output "role_session_name" {
  description = "The session name Expel will use when authenticating"
  value       = var.expel_assume_role_session_name
}

output "aws_region" {
  description = "The AWS Region where the CloudTrail resources exist"
  value       = local.region
}

output "sqs_queue_url" {
  description = "URL of the queue consuming from the S3 bucket"
  value       = aws_sqs_queue.cloudtrail_queue.url
}
