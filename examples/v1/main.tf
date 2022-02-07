provider "aws" {
  region = "us-east-1"
}

module "expel_aws_cloudtrail_integration" {
  source                           = "../../"

  expel_aws_account_arn            = "Replace with Expel's AWS account ARN here"
  expel_customer_organization_guid = "Replace with your organization GUID -- (this unique identifier is assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench)"

  expel_assume_role_session_name = "ExpelServiceAssumeRoleForCloudTrailAccess"
  enable_s3_encryption = true
  enable_sqs_encryption = true
  queue_message_retention_days = 10

  prefix = "expel-cloudtrail-integration"

  tags = {}
}

output "integration" {
  value = module.expel_aws_cloudtrail_integration
}
