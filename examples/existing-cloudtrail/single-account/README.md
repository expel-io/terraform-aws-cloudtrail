# Existing

This configuration creates AWS resources that are necessary to integrate Expel Workbench with an existing AWS CloudTrail instance.

## Usage

To run this example you need to execute:

```bash
terraform init
terraform apply -var-file="terraform.tfvars"
```

Note that this example may create resources which can cost money, run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | = 1.1.3 |
| aws | = 4.0 |
