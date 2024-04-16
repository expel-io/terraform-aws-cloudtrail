# Variables
variable "region" {
  type = string
}

variable "expel_customer_organization_guid" {
  description = "Expel organization GUID"
  type        = string
}

# AWS provider
provider "aws" {
  region = var.region
}

# Expel AWS CloudTrail module
module "expel_aws_cloudtrail_integration" {
  source = "../../"

  providers = {
    aws.log_bucket = aws # Default AWS provider for new CloudTrail
  }

  expel_customer_organization_guid = var.expel_customer_organization_guid
  enable_organization_trail        = false

  expel_assume_role_session_name          = "ExpelServiceAssumeRoleForCloudTrailAccess"
  queue_message_retention_days            = 10
  enable_sqs_encryption                   = true
  enable_cloudtrail_log_file_validation   = true
  enable_bucket_access_logging            = true
  enable_access_logging_bucket_encryption = true
  enable_bucket_versioning                = true
  enable_bucket_encryption_key_rotation   = true

  prefix = "expel-aws-cloudtrail"
  tags = {
    "is_external" = "true"
  }
}

# Output
output "expel_aws_cloudtrail_integration" {
  value = module.expel_aws_cloudtrail_integration
}
