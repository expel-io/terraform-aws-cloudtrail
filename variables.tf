variable "expel_aws_account_arn" {
  description = "Expel's AWS Account ARN to allow assuming role to gain CloudTrail access"
  type        = string
}

variable "expel_customer_organization_guid" {
  description = "Expel customer's organization GUID (this unique identifier is assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench)"
  type        = string
}

variable "expel_assume_role_session_name" {
  description = "The session name Expel will use when authenticating"
  type        = string
  default     = "ExpelCloudTrailServiceSession"
}

variable "prefix" {
  // TODO enforce max length with a validator - should not exceed bucket (63), cloudtrail and sqs max length (80)
  description = "A prefix to group all Expel integration resources."
  default     = "expel-aws-integration"
}

variable "tags" {
  description = "A set of tags to group resources"
  default     = {}
}

variable "queue_message_retention_days" {
  description = "The visibility timeout for the queue. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html"
  type        = number
  default     = 7
}

variable "sqs_managed_sse_enabled" {
  description = "Enable server-side encryption (SSE) of message content with SQS-owned encryption keys"
  type        = bool
  default     = true
}
