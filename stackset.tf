resource "aws_cloudformation_stack_set" "permeate_account_policy" {
  count = local.create_stackset ? 1 : 0

  name             = "PermeateAccountPolicy"
  description      = "Creates policies in all accounts of the organization for Expel to get basic read permissions of resources in order to investigate alerts"
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  auto_deployment {
    enabled = true
  }

  parameters = {
    ExpelCustomerOrganizationGUID = var.expel_customer_organization_guid
    ExpelAccountARN               = var.expel_aws_user_arn
    ExpelRoleName                 = var.expel_assume_role_name
  }

  template_body = local.stackset_template

  tags = local.tags
}


resource "aws_cloudformation_stack_set_instance" "permeate_account_policy" {
  count = local.create_stackset ? 1 : 0

  deployment_targets {
    organizational_unit_ids = [local.customer_aws_organization_id]
  }

  operation_preferences {
    failure_tolerance_count = var.stackset_fault_tolerance_count
    max_concurrent_count    = var.stackset_max_concurrent_count
  }

  region         = local.region
  stack_set_name = aws_cloudformation_stack_set.permeate_account_policy[0].name
}
