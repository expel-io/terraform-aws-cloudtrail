# AWS CloudTrail Terraform Module

This Terraform module sets up an integration between Expel and an existing AWS CloudTrail in a cross-account scenario.

## Table of Contents

- [Variables](#variables)
- [Provider](#provider)
- [Module](#module)
- [Output](#output)
- [Usage](#usage)
- [Prerequisites](#prerequisites)

## Variables

It is recommended that variables are stored in a separate file, such as `terraform.tfvars` or `variables.tf` to avoid hardcoding sensitive information in the main configuration file.

- `region`: The AWS region where the CloudTrail setup exists.
- `expel_customer_organization_guid`: The organization GUID assigned by Expel.
- `existing_cloudtrail_bucket_name`: The name of the AWS CloudTrail S3 bucket.
- `aws_management_account_id`: The AWS management account ID.
- `existing_cloudtrail_log_bucket_account_id`: The account ID of the AWS CloudTrail log bucket.
- `existing_cloudtrail_kms_key_arn`: The ARN of the AWS KMS Key used for the CloudTrail infrastructure.
- `existing_sns_topic_arn`: The ARN of the AWS CloudTrail SNS topic.

## Provider

- `aws`: The AWS provider used to create the CloudTrail resources. The region is set to "us-east-1" and uses the "default" profile for authentication.

## Module

- `expel_aws_cloudtrail_integration_x_account`: The Expel AWS CloudTrail module. This module sets up an existing CloudTrail with resources in different accounts. It uses an existing CloudTrail log bucket and sets up the necessary configurations for cross-account access.

## Output

- `expel_aws_cloudtrail_integration_x_account`: The output of the `expel_aws_cloudtrail_integration_x_account` module. This output can be used to reference the module's resources in other parts of your Terraform configuration.

## Usage

Follow these steps to deploy the configuration:

1. Install and configure the AWS CLI. Refer to the official AWS CLI documentation for installation instructions.
2. Initialize Terraform in your working directory. This will download the necessary provider plugins.
3. Ensure that you have `terraform.tfvars` file in the working directory with all the necessary variables:

```sh
terraform init
terraform apply -var-file="terraform.tfvars"
```

**Note**: This configuration may create resources that incur costs in AWS. To avoid unnecessary charges, run the `terraform destroy` command to remove these resources when they are no longer needed.

## Prerequisites

Ensure you have the following software installed on your machine:

| Software | Version |
|----------|---------|
| Terraform | = 1.1.3 |
| AWS Provider | = 4.0 |

Refer to the official Terraform documentation and AWS Provider documentation for installation instructions.
