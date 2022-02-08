variable "region" {
  type = string
}

variable "expel_aws_account_arn" {
  description = "Use Expel's AWS account ARN here"
  type        = string
}

variable "expel_customer_organization_guid" {
  description = "Use your organization GUID -- (this unique identifier is assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench)"
  type        = string
}

provider "aws" {
  region = "${var.region}"
}

module "expel_aws_cloudtrail_integration" {
  source = "../../"

  expel_aws_account_arn            = "${var.expel_aws_account_arn}"
  expel_customer_organization_guid = "${var.expel_customer_organization_guid}"
  expel_assume_role_session_name   = "ExpelServiceAssumeRoleForCloudTrailAccess"
  enable_s3_encryption             = true
  enable_sqs_encryption            = true
  queue_message_retention_days     = 10

  prefix = "expel-cloudtrail-integration"
  tags = {
    "is_external" = "true"
  }
}

output "expel_aws_cloudtrail_integration" {
  value = module.expel_aws_cloudtrail_integration
}
