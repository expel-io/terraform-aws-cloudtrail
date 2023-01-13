# terraform-aws-cloudtrail

Terraform module for configuring AWS to integrate with [Expel Workbench](https://workbench.expel.io/).

Configures a CloudTrail stack (CloudTrail & S3 bucket) with a notification queue that
[Expel Workbench](https://workbench.expel.io/) consumes. Cloudtrail, S3 bucket, SQS and SNS (optionally for existing Cloudtrail) queue are encrypted by default using a custom managed KMS key.

## Usage

```hcl
module "expel_aws_cloudtrail" {
  source  = "expel-io/cloudtrail/aws"
  version = "1.3.0"

  expel_customer_organization_guid = "Replace with your organization GUID from Expel Workbench"
  region = "AWS region in which notification queue for CloudTrail will be created"
}
```

Once you have configured your AWS environment, go to
https://workbench.expel.io/settings/security-devices?setupIntegration=aws and create an AWS CloudTrail
security device to enable Expel to begin monitoring your AWS environment.

## Permissions

The permissions allocated by this module allow Expel Workbench to perform investigations and get a broad understanding of your AWS footprint.

## Use Cases

1. Creating a new AWS CloudTrail for an AWS organization (default)
2. Creating a new AWS CloudTrail for a single AWS account (Set [enable_organization_trail](#input_enable_organization_trail) input to false)
3. Reusing an existing AWS Cloudtrail for a single AWS account or an AWS organization with all the existing resources deployed in the same account (Set [existing_cloudtrail_bucket_name](#input_existing_cloudtrail_bucket_name) input to the name of the existing log bucket)

## Limitations

- This module only supports integrating with Expel when all the necessary resources are deployed in the same account.
- This module **does not** support integrating with Expel when all the necessary resources are deployed across multiple aws accounts.
  > Ex. ControlTower Environments are **not supported** via this module. To integrate an AWS ControlTower environment with Expel refer to this [guide](https://support.expel.io/hc/en-us/articles/12391858961171-AWS-CloudTrail-Existing-CloudTrail-with-Control-Tower-setup-for-Workbench) in order to do so.

Please contact your Engagement Manager if you have an existing CloudTrail with a different configuration.

<!-- begin-tf-docs -->

## Requirements

| Name                                                                     | Version  |
| ------------------------------------------------------------------------ | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | >= 4.0.0 |
| <a name="requirement_random"></a> [random](#requirement_random)          | >= 3.1.3 |

## Inputs

| Name                                                                                                                                                   | Description                                                                                                                                                                                                                                                                                               | Type     | Default                                              | Required |
| ------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------- | :------: |
| <a name="input_expel_customer_organization_guid"></a> [expel_customer_organization_guid](#input_expel_customer_organization_guid)                      | Expel customer's organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench.                                                                                                                                             | `string` | n/a                                                  |   yes    |
| <a name="input_enable_access_logging_bucket_encryption"></a> [enable_access_logging_bucket_encryption](#input_enable_access_logging_bucket_encryption) | Enable to encrypt objects in the access logging bucket.                                                                                                                                                                                                                                                   | `bool`   | `true`                                               |    no    |
| <a name="input_enable_bucket_access_logging"></a> [enable_bucket_access_logging](#input_enable_bucket_access_logging)                                  | Access logging provides detailed records for the requests that are made to an Amazon S3 bucket.                                                                                                                                                                                                           | `bool`   | `true`                                               |    no    |
| <a name="input_enable_bucket_encryption_key_rotation"></a> [enable_bucket_encryption_key_rotation](#input_enable_bucket_encryption_key_rotation)       | If `enable_s3_encryption` is set to true, enabling key rotation will rotate the KMS keys used for S3 bucket encryption.                                                                                                                                                                                   | `bool`   | `true`                                               |    no    |
| <a name="input_enable_bucket_versioning"></a> [enable_bucket_versioning](#input_enable_bucket_versioning)                                              | Enable to protect against accidental/malicious removal or modification of S3 objects.                                                                                                                                                                                                                     | `bool`   | `true`                                               |    no    |
| <a name="input_enable_cloudtrail_log_file_validation"></a> [enable_cloudtrail_log_file_validation](#input_enable_cloudtrail_log_file_validation)       | Validates that a log file was not modified, deleted, or unchanged after CloudTrail delivered it.                                                                                                                                                                                                          | `bool`   | `true`                                               |    no    |
| <a name="input_enable_organization_trail"></a> [enable_organization_trail](#input_enable_organization_trail)                                           | For customers with AWS organizations setup, log events for the management account and all member accounts, and permeate IAM policies in all member accounts for Expel to get basic read permissions of resources in order to investigate alerts. Set to false if you want to onboard a single AWS account | `bool`   | `true`                                               |    no    |
| <a name="input_enable_sqs_encryption"></a> [enable_sqs_encryption](#input_enable_sqs_encryption)                                                       | Enable server-side encryption (SSE) of message content with SQS-owned encryption keys.                                                                                                                                                                                                                    | `bool`   | `true`                                               |    no    |
| <a name="input_existing_cloudtrail_bucket_name"></a> [existing_cloudtrail_bucket_name](#input_existing_cloudtrail_bucket_name)                         | The name of the existing bucket connected to the existing CloudTrail                                                                                                                                                                                                                                      | `string` | `null`                                               |    no    |
| <a name="input_existing_cloudtrail_kms_key_arn"></a> [existing_cloudtrail_kms_key_arn](#input_existing_cloudtrail_kms_key_arn)                         | The ARN of the KMS key used to encrypt existing CloudTrail bucket                                                                                                                                                                                                                                         | `string` | `null`                                               |    no    |
| <a name="input_existing_sns_topic_arn"></a> [existing_sns_topic_arn](#input_existing_sns_topic_arn)                                                    | The ARN of the existing SNS Topic configured to be notified by the existing CloudTrail bucket. The S3 bucket notification configuration must have the s3:ObjectCreated:\* event type checked.                                                                                                             | `string` | `null`                                               |    no    |
| <a name="input_expel_assume_role_session_name"></a> [expel_assume_role_session_name](#input_expel_assume_role_session_name)                            | The session name Expel will use when authenticating.                                                                                                                                                                                                                                                      | `string` | `"ExpelCloudTrailServiceSession"`                    |    no    |
| <a name="input_expel_aws_account_arn"></a> [expel_aws_account_arn](#input_expel_aws_account_arn)                                                       | Expel's AWS Account ARN to allow assuming role to gain CloudTrail access.                                                                                                                                                                                                                                 | `string` | `"arn:aws:iam::012205512454:user/ExpelCloudService"` |    no    |
| <a name="input_expel_customer_aws_account_id"></a> [expel_customer_aws_account_id](#input_expel_customer_aws_account_id)                               | Account id of customer's AWS account that will be monitored by Expel if it is different than the one terraform is using. This should be the management account id if organization trail is enabled.                                                                                                       | `string` | `null`                                               |    no    |
| <a name="input_prefix"></a> [prefix](#input_prefix)                                                                                                    | A prefix to group all Expel integration resources.                                                                                                                                                                                                                                                        | `string` | `"expel-aws-cloudtrail"`                             |    no    |
| <a name="input_queue_message_retention_days"></a> [queue_message_retention_days](#input_queue_message_retention_days)                                  | The visibility timeout for the queue. See: https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html                                                                                                                                                         | `number` | `7`                                                  |    no    |
| <a name="input_stackset_fault_tolerance_count"></a> [stackset_fault_tolerance_count](#input_stackset_fault_tolerance_count)                            | The number of accounts, per Region, for which stackset deployment operation can fail before AWS CloudFormation stops the operation in that Region.                                                                                                                                                        | `number` | `null`                                               |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                                                          | A set of tags to group resources.                                                                                                                                                                                                                                                                         | `map`    | `{}`                                                 |    no    |

## Outputs

| Name                                                                                   | Description                                                            |
| -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| <a name="output_aws_region"></a> [aws_region](#output_aws_region)                      | The AWS Region where the CloudTrail resources exist                    |
| <a name="output_role_arn"></a> [role_arn](#output_role_arn)                            | IAM Role ARN of the role for Expel to assume to access CloudTrail data |
| <a name="output_role_session_name"></a> [role_session_name](#output_role_session_name) | The session name Expel will use when authenticating                    |
| <a name="output_sqs_queue_url"></a> [sqs_queue_url](#output_sqs_queue_url)             | URL of the queue consuming from the S3 bucket                          |

## Resources

| Name                                                                                                                                                                                                                                               | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudformation_stack_set.permeate_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set)                                                                                       | resource    |
| [aws_cloudformation_stack_set_instance.permeate_account_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack_set_instance)                                                                     | resource    |
| [aws_cloudtrail.cloudtrail](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudtrail)                                                                                                                                | resource    |
| [aws_iam_policy.cloudtrail_manager_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                                                             | resource    |
| [aws_iam_role.expel_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                                                                             | resource    |
| [aws_iam_role_policy_attachment.cloudtrail_manager_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                                                 | resource    |
| [aws_kms_key.cloudtrail_bucket_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                                                                | resource    |
| [aws_kms_key.notification_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                                                                                                     | resource    |
| [aws_s3_bucket.cloudtrail_access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                                                                | resource    |
| [aws_s3_bucket.cloudtrail_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                                                                           | resource    |
| [aws_s3_bucket_acl.cloudtrail_access_log_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                                                    | resource    |
| [aws_s3_bucket_acl.cloudtrail_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl)                                                                                                               | resource    |
| [aws_s3_bucket_logging.cloudtrail_bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging)                                                                                                   | resource    |
| [aws_s3_bucket_notification.cloudtrail_bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification)                                                                                    | resource    |
| [aws_s3_bucket_policy.cloudtrail_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy)                                                                                                      | resource    |
| [aws_s3_bucket_public_access_block.cloudtrail_access_log_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                                    | resource    |
| [aws_s3_bucket_public_access_block.cloudtrail_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                                               | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail_access_log_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.cloudtrail_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration)            | resource    |
| [aws_s3_bucket_versioning.cloudtrail_access_log_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                                               | resource    |
| [aws_s3_bucket_versioning.cloudtrail_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                                                          | resource    |
| [aws_sns_topic.cloudtrail_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                                                                                                        | resource    |
| [aws_sns_topic_policy.sns_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy)                                                                                                              | resource    |
| [aws_sns_topic_subscription.cloudtrail_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)                                                                                 | resource    |
| [aws_sqs_queue.cloudtrail_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)                                                                                                                            | resource    |
| [aws_sqs_queue_policy.sqs_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy)                                                                                                             | resource    |
| [random_uuid.cloudtrail_bucket_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid)                                                                                                                          | resource    |
| [random_uuid.cloudtrail_sns_topic_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid)                                                                                                                       | resource    |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity)                                                                                                                      | data source |
| [aws_iam_policy_document.assume_role_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                                             | data source |
| [aws_iam_policy_document.cloudtrail_bucket_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                                       | data source |
| [aws_iam_policy_document.cloudtrail_key_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                                       | data source |
| [aws_iam_policy_document.cloudtrail_manager_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                                      | data source |
| [aws_iam_policy_document.notification_key_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                                     | data source |
| [aws_iam_policy_document.sns_queue_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                                               | data source |
| [aws_iam_policy_document.sns_topic_iam_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                                                                               | data source |
| [aws_organizations_organization.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/organizations_organization)                                                                                                | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                                                                                                                        | data source |

<!-- end-tf-docs -->
