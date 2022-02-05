# V1

This configuration sets up appropriate AWS resources necessary to connect Expel's Workbench with a new AWS CloudTrail instance

V1 is the simplest onboarding experience, as it assumes a single AWS Account is being onboarded with no pre-existing CloudTrail entity

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | = 1.1.3 |
| aws | = 3.71 |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| sqs_url | URL of the SQS queue used to notify Expel of new objects being inserted into CloudTrail's S3 bucket |