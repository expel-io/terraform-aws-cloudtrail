variable "expel_aws_account_arn" {
  type        = string
  description = "The arn of Expel's AWS Account to gather CloudTrail logs."
}

variable "expel_customer_organization_guid" {
  type        = string
  description = "The GUID of the customer's organization inside of the Expel Workbench."
}