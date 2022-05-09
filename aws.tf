data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_organizations_organization" "current" {}

locals {
  default_tags = {
    "vendor" = "expel"
  }

  tags = merge(
    var.tags,
    local.default_tags,
  )

  region                       = data.aws_region.current.name
  customer_aws_account_id      = data.aws_caller_identity.current.account_id
  customer_aws_organization_id = try(data.aws_organizations_organization.current.roots[0].id, "")
}
