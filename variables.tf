/* --- Set these to keep track of the effects of this module in your AWS infrastructure --- */
variable "prefix" {
  description = "A prefix to group all Expel integration resources."
  type        = string
  default     = "expel-aws-cloudtrail"

  validation {
    condition     = length(var.prefix) <= 26
    error_message = "Prefix value must be 26 characters or less."
  }
}

variable "tags" {
  description = "A set of tags to group resources."
  type        = map(string)
  default     = {}
}

/* --- Set these variables to enable connection with Expel Workbench --- */
variable "expel_customer_organization_guid" {
  description = "Expel customer's organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench."
  type        = string
}

variable "expel_customer_aws_account_id" {
  description = "Account id of customer's AWS account that will be monitored by Expel if it is different than the one terraform is using. This should be the management account id if organization trail is enabled."
  type        = string
  default     = null
  validation {
    condition     = var.expel_customer_aws_account_id == null || can(regex("^[0-9]{12}$", coalesce(var.expel_customer_aws_account_id, "")))
    error_message = "Account id must be 12 digits."
  }
}

variable "expel_aws_user_arn" {
  description = "Expel's AWS User ARN to allow assuming role to gain CloudTrail access."
  type        = string
  default     = "arn:aws:iam::012205512454:user/ExpelCloudService"
}

variable "expel_assume_role_name" {
  description = "The role name Expel will assume when authenticating."
  type        = string
  default     = "ExpelTrailAssumeRole"
}

variable "expel_assume_role_session_name" {
  description = "The session name Expel will use when authenticating."
  type        = string
  default     = "ExpelCloudTrailServiceSession"
}

variable "enable_organization_trail" {
  description = "For customers with AWS organizations setup, log events for the management account and all member accounts, and permeate IAM policies in all member accounts for Expel to get basic read permissions of resources in order to investigate alerts. Set to false if you want to onboard a single AWS account"
  type        = bool
  default     = true
}

/* --- Set these variables to support CloudTrail configuration --- */

variable "is_existing_cloudtrail_cross_account" {
  description = "For an existing cloudtrail, whether the cloudtrail & the log bucket (& optionally log bucket notifier topic if existing) are in different aws accounts"
  type        = bool
  default     = false
}
variable "existing_cloudtrail_bucket_name" {
  description = "The name of the existing bucket connected to the existing CloudTrail"
  type        = string
  default     = null
}

variable "aws_management_account_id" {
  description = "Account id of AWS management account."
  type        = string
  default     = null
  validation {
    condition     = var.aws_management_account_id == null || can(regex("^[0-9]{12}$", var.aws_management_account_id))
    error_message = "Account id must be 12 digits."
  }
}

variable "existing_cloudtrail_log_bucket_account_id" {
  description = "Account id of AWS account where the existing cloudtrail log bucket is created. This is where the new SQS queue will be created"
  type        = string
  default     = null
  validation {
    condition     = var.existing_cloudtrail_log_bucket_account_id == null || can(regex("^[0-9]{12}$", var.existing_cloudtrail_log_bucket_account_id))
    error_message = "Account id must be 12 digits."
  }
}

variable "existing_cloudtrail_kms_key_arn" {
  description = "The ARN of the KMS key used to encrypt existing CloudTrail bucket"
  type        = string
  default     = null
}

variable "existing_sns_topic_arn" {
  description = "The ARN of the existing SNS Topic configured to be notified by the existing CloudTrail bucket. The S3 bucket notification configuration must have the s3:ObjectCreated:* event type checked."
  type        = string
  default     = null
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

/* --- Set these variables to support new CloudTrail configuration --- */
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

variable "stackset_fault_tolerance_count" {
  description = "The number of accounts, per Region, for which stackset deployment operation can fail before AWS CloudFormation stops the operation in that Region."
  type        = number
  default     = null
}

variable "stackset_max_concurrent_count" {
  description = "The maximum number of accounts in which to perform this operation at one time. At most, this should be set to one more than `stackset_fault_tolerance_count`"
  type        = number
  default     = 1
}

variable "stackset_target_organizational_units" {
  description = "If the stackset is desired to be deployed to targeted OUs only, provide a list of OU ids. Please note that the OU that the trail log bucket account belongs to, must be included."
  type        = list(string)
  default     = null
}
