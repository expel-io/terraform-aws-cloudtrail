# AWS CloudTrail Terraform Module

Terraform module for configuring AWS to integrate with [Expel Workbench](https://workbench.expel.io/).

This Terraform module creates an AWS CloudTrail resource. It Configures a CloudTrail stack (CloudTrail & S3 bucket) with a notification queue that [Expel Workbench](https://workbench.expel.io/) consumes. Cloudtrail, S3 bucket, SQS and SNS (optionally for existing Cloudtrail) queue are encrypted by default using a custom managed KMS key.

## Table of Contents

- [Features](#features)
- [Usage](#usage)
- [Nota Bene](#nota-bene)
- [Examples](#examples)
- [Permissions](#permissions)
- [Use Cases](#use-cases)
- [Limitations](#limitations)
- [Issues](#issues)
- [Contributing](#contributing)
- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Resources](#resources)

## Features

- Conditionally creates a new CloudTrail resource based on the `existing_cloudtrail_bucket_name` variable.
- Sets the name of the CloudTrail trail using the `prefix` variable.
- Configures the trail to log events from all regions.
- Optionally enables log file integrity validation based on the `enable_cloudtrail_log_file_validation` variable.
- Specifies the ARN of the KMS key to use for encrypting the CloudTrail logs.
- Includes all management events with "All" read/write type in the CloudTrail logs.
- Ensures that the CloudTrail resource depends on the `cloudtrail_bucket_policy` resource, meaning that the bucket policy is applied before the CloudTrail is created.
- Applies specified tags to the CloudTrail resource.

## Usage

To use this module in your Terraform configuration, use the following syntax:

```terraform
module "expel_aws_cloudtrail" {
  source  = "expel-io/cloudtrail/aws"
  version = "2.0.0"

  providers = {
    aws.log_bucket = aws // Set the log_bucket alias to the default AWS provider for a new CloudTrail
  }

  expel_customer_organization_guid = "Replace with your organization GUID from Expel Workbench"
  region = "Replace with the AWS region in which the notification queue for CloudTrail will be created"
}
```

## Nota Bene

This module intentionally ignores certain configurations to maintain consistency with other methods of onboarding to AWS CloudTrail. Specifically, the rule `aws-cloudtrail-ensure-cloudwatch-integration`, which checks if CloudTrail logs are integrated with CloudWatch Logs, is being ignored.

This decision is intentional, and users should be aware that this is not being implemented in this case. For more details, refer to the [relevant section in the main.tf file](/main.tf).

## Permissions

The permissions allocated by this module allow Expel Workbench to perform investigations and get a broad understanding of your AWS footprint.

## Examples

You can find examples of how to use this module in the `examples` directory.

- [Basic](examples/basic)
- [Existing CloudTrail](examples/existing-cloudtrail)

This directory contains an example of how to use this module with an existing CloudTrail.

## Use Cases

1. Creating a new AWS CloudTrail for an AWS organization (default)
2. Creating a new AWS CloudTrail for a single AWS account (Set [enable_organization_trail](#input_enable_organization_trail) input to false)
3. Reusing an existing AWS Cloudtrail for a single AWS account or an AWS organization with all the existing resources deployed in the same account (Set [existing_cloudtrail_bucket_name](#input_existing_cloudtrail_bucket_name) input to the name of the existing log bucket)
4. Reusing an existing AWS Cloudtrail for an AWS organization with the existing resources deployed in the different accounts (Set [is_existing_cloudtrail_cross_account](#input_is_existing_cloudtrail_cross_account) to true, [existing_cloudtrail_bucket_name](#input_existing_cloudtrail_bucket_name) input to the name of the existing log bucket, [existing_cloudtrail_log_bucket_account_id](#input_existing_cloudtrail_log_bucket_account_id) to the aws account id where the cloudtrail log bucket resides and [aws_management_account_id](#input_aws_management_account_id) to the management account id of the aws organization)

## Limitations

- For existing cloudtrail with cross account resources deployment, this module only supports integrating with Expel when [AWS Organizations](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_introduction.html) is enabled. Additionally, if the cloudtrail log bucket is encrypted by an existing Customer Managed Key (CMK) that **does not** reside in the log bucket account, a new key policy needs to be added to the CMK that allows the `expel IAM role` created by the module in the log bucket account to perform `kms:Decrypt` action. Refer to [this guide](https://support.expel.io/hc/en-us/articles/12391858961171-AWS-CloudTrail-Existing-CloudTrail-with-Control-Tower-setup-for-Workbench#UUID-7931c0e3-f157-d464-2f19-fc51aaad5702_bridgehead-idm4579629317097633431279663831) for reference.
Please contact your Engagement Manager if you have an existing CloudTrail with a different configuration.
- For existing cloudtrail with cross account resources deployment, if you have an existing SNS topic configured as a notifier to the cloudtrail log bucket & the topic **does not** reside in the log bucket account, a new topic policy must be added that allows the log bucket account to perform `sns:Subscribe` action on the topic. Refer to [this aws documentation](https://docs.aws.amazon.com/sns/latest/dg/sns-send-message-to-sqs-cross-account.html) for details.

## Issues

Found a bug or have an idea for a new feature? Please [create an issue](https://github.com/expel-io/terraform-aws-cloudtrail/issues). We'll respond as soon as possible!

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the Project.
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`).
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the Branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

Please read our [Contributing Code of Conduct](CONTRIBUTING.md) to get started.

<!-- begin-tf-docs -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_expel_customer_organization_guid"></a> [expel\_customer\_organization\_guid](#input\_expel\_customer\_organization\_guid) | Expel customer's organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench. | `string` | n/a | yes |
| <a name="input_assume_role_arn"></a> [assume\_role\_arn](#input\_assume\_role\_arn) | ARN of the IAM role being assumed for resource creation | `string` | `null` | no |
| <a name="input_aws_management_account_id"></a> [aws\_management\_account\_id](#input\_aws\_management\_account\_id) | Account id of AWS management account. | `string` | `null` | no |
| <a name="input_enable_access_logging_bucket_encryption"></a> [enable\_access\_logging\_bucket\_encryption](#input\_enable\_access\_logging\_bucket\_encryption) | Enable to encrypt objects in the access logging bucket. | `bool` | `true` | no |
| <a name="input_enable_bucket_access_logging"></a> [enable\_bucket\_access\_logging](#input\_enable\_bucket\_access\_logging) | Access logging provides detailed records for the requests that are made to an Amazon S3 bucket. | `bool` | `true` | no |
| <a name="input_enable_bucket_encryption_key_rotation"></a> [enable\_bucket\_encryption\_key\_rotation](#input\_enable\_bucket\_encryption\_key\_rotation) | If `enable_s3_encryption` is set to true, enabling key rotation will rotate the KMS keys used for S3 bucket encryption. | `bool` | `true` | no |
| <a name="input_enable_bucket_versioning"></a> [enable\_bucket\_versioning](#input\_enable\_bucket\_versioning) | Enable to protect against accidental/malicious removal or modification of S3 objects. | `bool` | `true` | no |
| <a name="input_enable_cloudtrail_log_file_validation"></a> [enable\_cloudtrail\_log\_file\_validation](#input\_enable\_cloudtrail\_log\_file\_validation) | Validates that a log file was not modified, deleted, or unchanged after CloudTrail delivered it. | `bool` | `true` | no |
| <a name="input_enable_organization_trail"></a> [enable\_organization\_trail](#input\_enable\_organization\_trail) | For customers with AWS organizations setup, log events for the management account and all member accounts, and permeate IAM policies in all member accounts for Expel to get basic read permissions of resources in order to investigate alerts. Set to false if you want to onboard a single AWS account | `bool` | `true` | no |
| <a name="input_enable_sqs_encryption"></a> [enable\_sqs\_encryption](#input\_enable\_sqs\_encryption) | Enable server-side encryption (SSE) of message content with SQS-owned encryption keys. | `bool` | `true` | no |
| <a name="input_existing_cloudtrail_bucket_name"></a> [existing\_cloudtrail\_bucket\_name](#input\_existing\_cloudtrail\_bucket\_name) | The name of the existing bucket connected to the existing CloudTrail | `string` | `null` | no |
| <a name="input_existing_cloudtrail_kms_key_arn"></a> [existing\_cloudtrail\_kms\_key\_arn](#input\_existing\_cloudtrail\_kms\_key\_arn) | The ARN of the KMS key used to encrypt existing CloudTrail bucket | `string` | `null` | no |
| <a name="input_existing_cloudtrail_log_bucket_account_id"></a> [existing\_cloudtrail\_log\_bucket\_account\_id](#input\_existing\_cloudtrail\_log\_bucket\_account\_id) | Account id of AWS account where the existing cloudtrail log bucket is created. This is where the new SQS queue will be created | `string` | `null` | no |
| <a name="input_existing_notification_kms_key_arn"></a> [existing\_notification\_kms\_key\_arn](#input\_existing\_notification\_kms\_key\_arn) | The ARN of the KMS key used to encrypt new SQS/SNS. If provided, please add key policies to enable IAM permission for the account root, and allow `kms:GenerateDataKey` & `kms:Decrypt` actions to log bucket [principal:s3.amazonaws.com] & sns topic [principal:sns.amazonaws.com]. | `string` | `null` | no |
| <a name="input_existing_sns_topic_arn"></a> [existing\_sns\_topic\_arn](#input\_existing\_sns\_topic\_arn) | The ARN of the existing SNS Topic configured to be notified by the existing CloudTrail bucket. The S3 bucket notification configuration must have the s3:ObjectCreated:* event type checked. | `string` | `null` | no |
| <a name="input_expel_assume_role_name"></a> [expel\_assume\_role\_name](#input\_expel\_assume\_role\_name) | The role name Expel will assume when authenticating. | `string` | `"ExpelTrailAssumeRole"` | no |
| <a name="input_expel_assume_role_session_name"></a> [expel\_assume\_role\_session\_name](#input\_expel\_assume\_role\_session\_name) | The session name Expel will use when authenticating. | `string` | `"ExpelCloudTrailServiceSession"` | no |
| <a name="input_expel_aws_user_arn"></a> [expel\_aws\_user\_arn](#input\_expel\_aws\_user\_arn) | Expel's AWS User ARN to allow assuming role to gain CloudTrail access. | `string` | `"arn:aws:iam::012205512454:user/ExpelCloudService"` | no |
| <a name="input_expel_customer_aws_account_id"></a> [expel\_customer\_aws\_account\_id](#input\_expel\_customer\_aws\_account\_id) | Account id of customer's AWS account that will be monitored by Expel if it is different than the one terraform is using. This should be the management account id if organization trail is enabled. | `string` | `null` | no |
| <a name="input_is_existing_cloudtrail_cross_account"></a> [is\_existing\_cloudtrail\_cross\_account](#input\_is\_existing\_cloudtrail\_cross\_account) | For an existing cloudtrail, whether the cloudtrail & the log bucket (& optionally log bucket notifier topic if existing) are in different aws accounts | `bool` | `false` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A prefix to group all Expel integration resources. | `string` | `"expel-aws-cloudtrail"` | no |
| <a name="input_queue_message_retention_days"></a> [queue\_message\_retention\_days](#input\_queue\_message\_retention\_days) | The visibility timeout for the queue. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html | `number` | `7` | no |
| <a name="input_stackset_fault_tolerance_count"></a> [stackset\_fault\_tolerance\_count](#input\_stackset\_fault\_tolerance\_count) | The number of accounts, per Region, for which stackset deployment operation can fail before AWS CloudFormation stops the operation in that Region. | `number` | `null` | no |
| <a name="input_stackset_max_concurrent_count"></a> [stackset\_max\_concurrent\_count](#input\_stackset\_max\_concurrent\_count) | The maximum number of accounts in which to perform this operation at one time. At most, this should be set to one more than `stackset_fault_tolerance_count` | `number` | `1` | no |
| <a name="input_stackset_target_organizational_units"></a> [stackset\_target\_organizational\_units](#input\_stackset\_target\_organizational\_units) | If the stackset is desired to be deployed to targeted OUs only, provide a list of OU ids. Please note that the OU that the trail log bucket account belongs to, must be included. | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A set of tags to group resources. | `map(string)` | `{}` | no |
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
| [aws_cloudformation_stack_set.permeate_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set) | resource |
| [aws_cloudformation_stack_set_instance.permeate_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance) | resource |
| [aws_cloudtrail.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail) | resource |
| [aws_iam_policy.cloudtrail_manager_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.log_bucket_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.mgmt_expel_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudtrail_manager_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.log_bucket_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_key.cloudtrail_bucket_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.notification_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.cloudtrail_access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.cloudtrail_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.cloudtrail_bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.cloudtrail_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.cloudtrail_access_log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.cloudtrail_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail_access_log_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.cloudtrail_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail_access_log_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.cloudtrail_access_log_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.cloudtrail_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_sns_topic.cloudtrail_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.cloudtrail_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_sqs_queue.cloudtrail_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.sqs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [random_uuid.cloudtrail_bucket_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.cloudtrail_sns_topic_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudtrail_bucket_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_key_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cloudtrail_manager_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.log_bucket_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mgmt_assume_role_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.notification_key_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_queue_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sns_topic_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current_source_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
<!-- end-tf-docs -->
