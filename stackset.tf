resource "aws_cloudformation_stack_set" "permeate_account_policy" {
  count = var.enable_organization_trail ? 1 : 0

  name             = "PermeateAccountPolicy"
  description      = "Creates policies in all accounts of the organization for Expel to get basic read permissions of resources in order to investigate alerts"
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  auto_deployment {
    enabled = true
  }

  parameters = {
    ExpelCustomerOrganizationGUID = var.expel_customer_organization_guid,
    ExpelAssumeRoleARN            = aws_iam_role.expel_assume_role.arn
    ExpelRoleName                 = aws_iam_role.expel_assume_role.name
  }

  template_body = local.stackset_template

  tags = local.tags
}


resource "aws_cloudformation_stack_set_instance" "permeate_account_policy" {
  count = var.enable_organization_trail ? 1 : 0

  deployment_targets {
    organizational_unit_ids = [local.customer_aws_organization_id]
  }

  operation_preferences {
    failure_tolerance_count = var.stackset_fault_tolerance_count
  }

  region         = local.region
  stack_set_name = aws_cloudformation_stack_set.permeate_account_policy[0].name
}
