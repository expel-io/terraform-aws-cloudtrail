// it is a best practice for variables to have the following format:
// variable "<value>" {
//   description = "<description>"
//   type        = <type>
//   default     = "<default>"
// }

// As such I have updated the file to reflect this format

# This file contains the variable values for setting up an existing CloudTrail in a single AWS account.
# Replace the placeholder values with the appropriate values for your environment.

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
