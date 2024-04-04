# Integration with Existing AWS CloudTrail

This Terraform configuration sets up the necessary AWS resources for integrating Expel Workbench with an existing AWS CloudTrail instance.

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
