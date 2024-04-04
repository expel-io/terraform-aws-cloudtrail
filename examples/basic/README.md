# Basic AWS CloudTrail Setup

This Terraform configuration sets up the necessary AWS resources for integrating Expel Workbench with a new AWS CloudTrail instance.

The `Basic` configuration is designed for a simple onboarding experience, assuming a single AWS Account is being onboarded with a new CloudTrail entity.

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
