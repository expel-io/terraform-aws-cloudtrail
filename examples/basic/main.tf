variable "region" {
  type = string
}

variable "expel_customer_organization_guid" {
  description = "Use your organization GUID -- (this unique identifier is assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench)"
  type        = string
}

provider "aws" {
  region = var.region
}

module "expel_aws_cloudtrail_integration" {
  source = "../../"

  expel_customer_organization_guid        = var.expel_customer_organization_guid
  expel_assume_role_session_name          = "ExpelServiceAssumeRoleForCloudTrailAccess"
  queue_message_retention_days            = 10

  enable_sqs_encryption                   = true
  enable_cloudtrail_bucket_encryption     = true
  enable_cloudtrail_log_file_validation   = true
  enable_bucket_access_logging            = true
  enable_access_logging_bucket_encryption = true
  enable_bucket_versioning                = true
  enable_bucket_encryption_key_rotation   = true

  prefix = "expel-cloudtrail-integration"
  tags = {
    "is_external" = "true"
  }
}

output "expel_aws_cloudtrail_integration" {
  value = module.expel_aws_cloudtrail_integration
}
