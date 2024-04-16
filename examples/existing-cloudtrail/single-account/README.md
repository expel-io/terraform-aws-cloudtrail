# Expel AWS CloudTrail Integration Terraform Module

This Terraform configuration sets up the necessary AWS resources for integrating Expel Workbench with an existing CloudTrail infrastructure in a single AWS account.

The `Existing CloudTrail` configuration is designed for customers who have an existing CloudTrail setup and want to integrate it with Expel Workbench. This configuration assumes that the CloudTrail S3 bucket, KMS key, and SNS topic have already been created in the AWS account.

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
- `existing_cloudtrail_kms_key_arn`: The ARN of the AWS KMS Key used for the CloudTrail infrastructure.
- `existing_sns_topic_arn`: The ARN of the AWS CloudTrail SNS topic.

## Provider

- `aws`: The AWS provider used to create the CloudTrail resources. The region is set to "us-east-1" and uses the "default" profile for authentication.

## Module

- `expel_aws_cloudtrail_integration`:  The Expel AWS CloudTrail module. It requires several input variables, including the path to the module source code, a map of provider aliases and their corresponding provider configurations, and various settings related to the CloudTrail resources.

## Output

- `expel_aws_cloudtrail_integration_existing`: The output of the `expel_aws_cloudtrail_integration_existing` module. This output can be used to reference the module's resources in other parts of your Terraform configuration.

## Usage

Follow these steps to deploy the configuration:

1. Initialize Terraform in your working directory. This will download the necessary provider plugins.
2. Apply the Terraform configuration. Ensure you have a `terraform.tfvars` file in your working directory with all the necessary variables:

```sh
terraform init
terraform apply -var-file="terraform.tfvars"
```

**Note**: This configuration may create resources that incur costs in AWS (such as an AWS S3 bucket). To avoid unnecessary charges, run the `terraform destroy` command to remove these resources when they are no longer needed.

## Prerequisites

Ensure you have the following software installed on your machine:

| Software | Version |
|------|---------|
| terraform | = 1.1.3 |
| aws | = 4.0 |

Refer to the official Terraform documentation and AWS Provider documentation for installation instructions.
