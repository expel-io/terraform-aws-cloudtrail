output "sqs_queue_url" {
  description = "URL of the queue consuming from the S3 bucket"
  value       = aws_sqs_queue.cloudtrail_queue.url
}
