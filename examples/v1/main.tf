provider "aws" {
  region = "us-east-1"
}

module "expel_aws_cloudtrail_integration" {
  source                           = "../../"
  expel_aws_account_arn            = var.expel_aws_account_arn
  expel_customer_organization_guid = var.expel_customer_organization_guid
}

output "integration" {
  value = module.expel_aws_cloudtrail_integration
}
