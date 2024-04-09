# Basic AWS CloudTrail Setup

This Terraform configuration sets up the necessary AWS resources for integrating Expel Workbench with a new AWS CloudTrail instance.

The `Basic` configuration is designed for a simple onboarding experience, assuming a single AWS Account is being onboarded with a new CloudTrail entity.

## Variables

- `region`: The AWS region where the CloudTrail resources will be created.
- `expel_customer_organization_guid`: The organization GUID assigned by Expel for the integration. This GUID can be found in the browser URL after navigating to Settings > My Organization in Workbench.

## Provider

- `aws`: The AWS provider used to create the CloudTrail resources. The region is set based on the value of the "region" variable.

## Module

- `expel_aws_cloudtrail_integration`: The Expel AWS CloudTrail module. It requires several input variables, including the path to the module source code, a map of provider aliases and their corresponding provider configurations, and various settings related to the CloudTrail resources.

## Output

- `expel_aws_cloudtrail_integration`: The output of the `expel_aws_cloudtrail_integration` module. This output can be used to reference the module's resources in other parts of your Terraform configuration.

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
|----------|---------|
| Terraform | = 1.1.3 |
| AWS Provider | = 4.0 |

Refer to the official Terraform documentation and AWS Provider documentation for installation instructions.
