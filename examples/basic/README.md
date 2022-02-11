# Basic

This configuration sets up appropriate AWS resources that are necessary to integrate Expel's Workbench with a new AWS CloudTrail instance.

This `Basic` example is the simplest onboarding experience, as it assumes a single AWS Account is being onboarded with a new CloudTrail entity.

## Usage


To run this example you need to execute:

```bash
terraform init
terraform apply -var-file="terraform.tfvars"
```

Note that this example may create resources which can cost money (AWS S3 bucket, for example). Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | = 1.1.3 |
| aws | = 4.0 |