output "role_arn" {
  description = "IAM Role ARN of the role for Expel to assume to access CloudTrail data"
  value       = aws_iam_role.expel_assume_role.arn
}

output "role_session_name" {
  description = "The session name Expel will use when authenticating"
  value       = var.expel_assume_role_session_name
}

output "aws_region" {
  description = "The AWS Region where the CloudTrail resources exist"
  value       = data.aws_region.current.name
}

output "sqs_queue_url" {
  description = "URL of the queue consuming from the S3 bucket"
  value       = aws_sqs_queue.cloudtrail_queue.url
}
