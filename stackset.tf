# This resource block defines an AWS CloudFormation Stack Set named "PermeateAccountPolicy".
# It creates policies in all accounts of the organization for Expel to get basic read permissions of resources in order to investigate alerts.
# The stack set is conditionally created based on the value of the local variable "create_stackset".
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

# This resource block defines an AWS CloudFormation Stack Set Instance for the "PermeateAccountPolicy" stack set.
# It specifies the deployment targets as organizational units defined in the local variable "stackset_organization_units".
# The operation preferences are set based on the values of the variables "stackset_fault_tolerance_count" and "stackset_max_concurrent_count".
# The region and stack set name are also specified.
resource "aws_cloudformation_stack_set_instance" "permeate_account_policy" {
  count = local.create_stackset ? 1 : 0

  deployment_targets {
    organizational_unit_ids = local.stackset_organization_units
  }

  operation_preferences {
    failure_tolerance_count = var.stackset_fault_tolerance_count
    max_concurrent_count    = var.stackset_max_concurrent_count
  }

  region         = local.region
  stack_set_name = aws_cloudformation_stack_set.permeate_account_policy[0].name
}
