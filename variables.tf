variable "expel_customer_organization_guid" {
  description = "Expel customer's organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench."
  type        = string
}

variable "expel_aws_account_arn" {
  description = "Expel's AWS Account ARN to allow assuming role to gain CloudTrail access."
  type        = string
  default     = "arn:aws:iam::012205512454:user/ExpelCloudService"
}

variable "expel_assume_role_session_name" {
  description = "The session name Expel will use when authenticating."
  type        = string
  default     = "ExpelCloudTrailServiceSession"
}

variable "enable_organization_trail" {
  description = "When enabled, log events for the management account and all member accounts."
  type        = bool
  default     = false
}

variable "prefix" {
  description = "A prefix to group all Expel integration resources."
  type        = string
  default     = "expel-aws-integration"

  validation {
    condition     = length(var.prefix) <= 32
    error_message = "Prefix value must be 32 characters or less."
  }
}

variable "tags" {
  description = "A set of tags to group resources."
  default     = {}
}

variable "queue_message_retention_days" {
  description = "The visibility timeout for the queue. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html"
  type        = number
  default     = 7
}

variable "enable_sqs_encryption" {
  description = "Enable server-side encryption (SSE) of message content with SQS-owned encryption keys."
  type        = bool
  default     = true
}

variable "enable_cloudtrail_bucket_encryption" {
  description = "Enable to encrypt objects in the cloudtrail bucket."
  type        = bool
  default     = true
}

variable "enable_cloudtrail_log_file_validation" {
  description = "Validates that a log file was not modified, deleted, or unchanged after CloudTrail delivered it."
  type        = bool
  default     = true
}

variable "enable_bucket_access_logging" {
  description = "Access logging provides detailed records for the requests that are made to an Amazon S3 bucket."
  type        = bool
  default     = true
}

variable "enable_access_logging_bucket_encryption" {
  description = "Enable to encrypt objects in the access logging bucket."
  type        = bool
  default     = true
}

variable "enable_bucket_versioning" {
  description = "Enable to protect against accidental/malicious removal or modification of S3 objects."
  type        = bool
  default     = true
}

variable "enable_bucket_encryption_key_rotation" {
  description = "If `enable_s3_encryption` is set to true, enabling key rotation will rotate the KMS keys used for S3 bucket encryption."
  type        = bool
  default     = true
}
