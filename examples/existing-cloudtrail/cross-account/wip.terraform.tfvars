// it is a best practice for variables to have the following format:
// variable "<value>" {
//   description = "<description>"
//   type        = <type>
//   default     = "<default>"
// }

// As such I have updated the file to reflect this format

# This file contains the variable values for setting up an existing CloudTrail
# with cross-account notifications.
#
# Replace the placeholder values with the appropriate values for
# your environment.

variable "region" {
  description = "AWS region for the notification queue for CloudTrail"
  type        = string
  default     = "us-east-1" # Replace with your AWS region
}

variable "expel_customer_organization_guid" {
  description = "Organization GUID assigned by Expel"
  type        = string
  default     = "" # Replace with your organization GUID
}

variable "existing_cloudtrail_bucket_name" {
  description = "AWS S3 Bucket name for CloudTrail"
  type        = string
  default     = "" # Replace with your S3 bucket name
}

variable "aws_management_account_id" {
  description = "AWS Management account ID"
  type        = string
  default     = "" # Replace with your AWS Management account ID
}

variable "existing_cloudtrail_log_bucket_account_id" {
  description = "AWS CloudTrail log bucket account ID"
  type        = string
  default     = "" # Replace with your log bucket account ID
}

variable "existing_cloudtrail_kms_key_arn" {
  description = "KMS Key ARN used for CloudTrail S3 Bucket"
  type        = string
  default     = "" # Replace with your KMS Key ARN
}

variable "existing_sns_topic_arn" {
  description = "AWS SNS Topic ARN"
  type        = string
  default     = "" # Replace with your SNS Topic ARN
}
