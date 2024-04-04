# This Terraform configuration file sets up an integration with Expel for AWS CloudTrail.
# It creates an AWS provider, sets up the necessary variables, and configures the Expel AWS CloudTrail module.
# The module is responsible for creating and managing the CloudTrail resources, such as S3 bucket, SQS queue, and CloudTrail trail.
# The integration can be customized by modifying the input variables provided to the module.

# Variables:
# - region: The AWS region where the CloudTrail resources will be created.
# - expel_customer_organization_guid: The organization GUID assigned by Expel for the integration.
#   This GUID can be found in the browser URL after navigating to Settings > My Organization in Workbench.
variable "region" {
  type = string
}

variable "expel_customer_organization_guid" {
  description = "Use your organization GUID assigned to you by Expel."
  type        = string
}

# Provider:
# - aws: The AWS provider used to create the CloudTrail resources.
#   The region is set based on the value of the "region" variable.
provider "aws" {
  region = var.region
}

# Module:
# - expel_aws_cloudtrail_integration: The Expel AWS CloudTrail module.
#   It requires the following input variables:
#   - source: The path to the module source code.
#   - providers: A map of provider aliases and their corresponding provider configurations.
#     In this case, the "aws.log_bucket" alias is set to the default AWS provider for the new CloudTrail.
#   - expel_customer_organization_guid: The organization GUID assigned by Expel.
#   - enable_organization_trail: Whether to enable organization trail (default: false).
#   - expel_assume_role_session_name: The session name for assuming the role for CloudTrail access.
#   - queue_message_retention_days: The number of days to retain messages in the SQS queue.
#   - enable_sqs_encryption: Whether to enable encryption for the SQS queue.
#   - enable_cloudtrail_log_file_validation: Whether to enable log file validation for CloudTrail.
#   - enable_bucket_access_logging: Whether to enable access logging for the S3 bucket.
#   - enable_access_logging_bucket_encryption: Whether to enable encryption for the access logging bucket.
#   - enable_bucket_versioning: Whether to enable versioning for the S3 bucket.
#   - enable_bucket_encryption_key_rotation: Whether to enable rotation of the encryption key for the S3 bucket.
#   - prefix: The prefix to use for naming the CloudTrail resources.
#   - tags: A map of tags to apply to the CloudTrail resources.
module "expel_aws_cloudtrail_integration" {
  source = "../../"

  providers = {
    aws.log_bucket = aws # setting the log_bucket alias to default aws provider for new cloudtrail
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

# Output:
output "expel_aws_cloudtrail_integration" {
  value = module.expel_aws_cloudtrail_integration
}
