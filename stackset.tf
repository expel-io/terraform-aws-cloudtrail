# (WIP) cloudformation stackset for multi-account iam policies

data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_assume_role_policy" {
  count = var.enable_organization_trail ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetAdministrationRole" {
  count = var.enable_organization_trail ? 1 : 0

  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy[0].json
  name               = "AWSCloudFormationStackSetAdministrationRole"

  tags = local.tags
}

resource "aws_cloudformation_stack_set" "permeate_account_policy" {
  count = var.enable_organization_trail ? 1 : 0

  name             = "PermeateAccountPolicy"
  description      = "TODO"
  permission_model = "SERVICE_MANAGED"
  capabilities     = ["CAPABILITY_NAMED_IAM"]

  auto_deployment {
    enabled = true
  }

  parameters = {
    ExpelCustomerOrganizationGUID = var.expel_customer_organization_guid,
    ExpelAssumeRoleARN            = aws_iam_role.expel_assume_role.arn
  }

  template_body = local.stackset_template

  tags = local.tags
}

data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy" {
  count = var.enable_organization_trail ? 1 : 0

  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/${aws_cloudformation_stack_set.permeate_account_policy[0].execution_role_name}"]
  }
}

resource "aws_iam_role_policy" "AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy" {
  count = var.enable_organization_trail ? 1 : 0

  name   = "ExecutionPolicy"
  policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy[0].json
  role   = aws_iam_role.AWSCloudFormationStackSetAdministrationRole[0].name
}

resource "aws_cloudformation_stack_set_instance" "permeate_account_policy" {
  count = var.enable_organization_trail ? 1 : 0

  deployment_targets {
    organizational_unit_ids = [local.customer_aws_organization_id]
  }

  region         = local.region
  stack_set_name = aws_cloudformation_stack_set.permeate_account_policy[0].name
}