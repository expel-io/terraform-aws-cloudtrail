# terraform-aws-cloudtrail
Terraform module for configuring AWS to integrate with [Expel Workbench](https://workbench.expel.io/).

Configures a CloudTrail stack (CloudTrail & S3 bucket) with a notification queue that
[Expel Workbench](https://workbench.expel.io/) consumes. Cloudtrail, S3 bucket and SQS queue are encrypted by default using a custom managed KMS key.

## Usage
```hcl
module "expel_aws_cloudtrail" {
  source  = "expel-io/terraform-aws-cloudtrail"
  version = "1.0.0"

  expel_customer_organization_guid = "Replace with your organization GUID from Expel Workbench"
  region = "AWS region in which notification queue for CloudTrail will be created"
}
```
Once you have configured your AWS environment, go to
https://workbench.expel.io/settings/security-devices?setupIntegration=aws and create an AWS CloudTrail
security device to enable Expel to begin monitoring your AWS environment.

## Permissions
The permissions allocated by this module allow Expel Workbench to perform investigations and get a broad understanding of your AWS footprint.

## Limitations
1. Only supports onboarding a single AWS account, not an entire AWS Organization.
2. Will always create a new CloudTrail, does not support re-using an existing CloudTrail.

See https://support.expel.io/hc/en-us/articles/360061333154-AWS-CloudTrail-getting-started-guide for options if you
have an AWS Organization or already have a CloudTrail you want to re-use.

<!-- begin-tf-docs -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0.0 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_expel_customer_organization_guid"></a> [expel\_customer\_organization\_guid](#input\_expel\_customer\_organization\_guid) | Expel customer's organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench. | `string` | n/a | yes |
| <a name="input_enable_access_logging_bucket_encryption"></a> [enable\_access\_logging\_bucket\_encryption](#input\_enable\_access\_logging\_bucket\_encryption) | Enable to encrypt objects in the access logging bucket. | `bool` | `true` | no |
| <a name="input_enable_bucket_access_logging"></a> [enable\_bucket\_access\_logging](#input\_enable\_bucket\_access\_logging) | Access logging provides detailed records for the requests that are made to an Amazon S3 bucket. | `bool` | `true` | no |
| <a name="input_enable_bucket_encryption_key_rotation"></a> [enable\_bucket\_encryption\_key\_rotation](#input\_enable\_bucket\_encryption\_key\_rotation) | If `enable_s3_encryption` is set to true, enabling key rotation will rotate the KMS keys used for S3 bucket encryption. | `bool` | `true` | no |
| <a name="input_enable_bucket_versioning"></a> [enable\_bucket\_versioning](#input\_enable\_bucket\_versioning) | Enable to protect against accidental/malicious removal or modification of S3 objects. | `bool` | `true` | no |
| <a name="input_enable_cloudtrail_log_file_validation"></a> [enable\_cloudtrail\_log\_file\_validation](#input\_enable\_cloudtrail\_log\_file\_validation) | Validates that a log file was not modified, deleted, or unchanged after CloudTrail delivered it. | `bool` | `true` | no |
| <a name="input_enable_organization_trail"></a> [enable\_organization\_trail](#input\_enable\_organization\_trail) | When enabled, log events for the management account and all member accounts. | `bool` | `false` | no |
| <a name="input_enable_sqs_encryption"></a> [enable\_sqs\_encryption](#input\_enable\_sqs\_encryption) | Enable server-side encryption (SSE) of message content with SQS-owned encryption keys. | `bool` | `true` | no |
| <a name="input_expel_assume_role_session_name"></a> [expel\_assume\_role\_session\_name](#input\_expel\_assume\_role\_session\_name) | The session name Expel will use when authenticating. | `string` | `"ExpelCloudTrailServiceSession"` | no |
| <a name="input_expel_aws_account_arn"></a> [expel\_aws\_account\_arn](#input\_expel\_aws\_account\_arn) | Expel's AWS Account ARN to allow assuming role to gain CloudTrail access. | `string` | `"arn:aws:iam::012205512454:user/ExpelCloudService"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A prefix to group all Expel integration resources. | `string` | `"expel-aws-integration"` | no |
| <a name="input_queue_message_retention_days"></a> [queue\_message\_retention\_days](#input\_queue\_message\_retention\_days) | The visibility timeout for the queue. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html | `number` | `7` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A set of tags to group resources. | `map` | `{}` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | The AWS Region where the CloudTrail resources exist |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | IAM Role ARN of the role for Expel to assume to access CloudTrail data |
| <a name="output_role_session_name"></a> [role\_session\_name](#output\_role\_session\_name) | The session name Expel will use when authenticating |
| <a name="output_sqs_queue_url"></a> [sqs\_queue\_url](#output\_sqs\_queue\_url) | URL of the queue consuming from the S3 bucket |
## Resources

| Name | Type |
|------|------|
| [aws_cloudtrail.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_policy.cloudtrail_manager_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.expel_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudtrail_manager_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.cloudtrail_bucket_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.cloudtrail_access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.cloudtrail_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.cloudtrail_access_log_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.cloudtrail_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_logging.cloudtrail_bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.cloudtrail_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.cloudtrail_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail_access_log_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail_access_log_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudtrail_access_log_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.cloudtrail_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_sqs_queue.cloudtrail_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.sqs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_iam_policy_document.assume_role_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_bucket_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_manager_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_bucket_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
<!-- end-tf-docs -->
