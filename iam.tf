resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail_bucket[0].bucket
  policy = data.aws_iam_policy_document.cloudtrail_bucket_iam_document[0].json
}

data "aws_iam_policy_document" "cloudtrail_bucket_iam_document" {
  count = var.existing_cloudtrail_bucket_name == null ? 1 : 0

  # Necessary to allow any bucket permissions
  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_bucket[0].arn]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  # Allow Cloudtrail to store objects in S3 bucket
  statement {
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.cloudtrail_bucket[0].arn}/*"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mgmt_assume_role_iam_document" {
  # Allow Expel Workbench to decrypt cloudtrail bucket
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.expel_aws_user_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.expel_customer_organization_guid]
    }
  }
}

resource "aws_iam_role" "mgmt_expel_assume_role" {
  name               = var.expel_assume_role_name
  assume_role_policy = data.aws_iam_policy_document.mgmt_assume_role_iam_document.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cloudtrail_manager_role_policy_attachment" {
  role       = aws_iam_role.mgmt_expel_assume_role.name
  policy_arn = aws_iam_policy.cloudtrail_manager_iam_policy.arn
}

resource "aws_iam_policy" "cloudtrail_manager_iam_policy" {
  name   = "${var.prefix}-cloudtrail-manager-policy"
  policy = data.aws_iam_policy_document.cloudtrail_manager_iam_document.json

  tags = local.tags
}

# ignoring as these policies enable necessary observability on all AWS resources
# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "cloudtrail_manager_iam_document" {
  # Allow Expel Workbench to get objects from cloudtrail bucket
  dynamic "statement" {
    for_each = var.is_existing_cloudtrail_cross_account ? [] : [1]
    content {
      actions   = ["s3:GetObject"]
      resources = ["${local.cloudtrail_bucket_arn}/*"]
      effect    = "Allow"
    }
  }

  # Allow Expel Workbench to receive and delete SQS messages
  dynamic "statement" {
    for_each = var.is_existing_cloudtrail_cross_account ? [] : [1]
    content {
      actions = [
        "sqs:DeleteMessage",
        "sqs:ReceiveMessage"
      ]
      resources = [aws_sqs_queue.cloudtrail_queue.arn]
      effect    = "Allow"
    }
  }

  # Allow Expel Workbench to decrypt cloudtrail bucket
  dynamic "statement" {
    for_each = (var.is_existing_cloudtrail_cross_account || local.cloudtrail_bucket_encryption_key_arn == null) ? [] : [1]
    content {
      actions   = ["kms:Decrypt"]
      resources = [local.cloudtrail_bucket_encryption_key_arn]
      effect    = "Allow"
    }
  }

  # Allow Expel Workbench to decrypt notifications
  dynamic "statement" {
    for_each = var.is_existing_cloudtrail_cross_account ? [] : [1]
    content {
      actions   = ["kms:Decrypt"]
      resources = [aws_kms_key.notification_encryption_key.arn]
      effect    = "Allow"
    }
  }

  # Note: This is a duplicate policy statement with CloudFormation StackSet "PermeateAccountPolicy"
  # Allow Expel Workbench to gather information about AWS footprint
  statement {
    actions = [
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:ListTrails",
      "cloudtrail:GetTrail",
      "config:GetDiscoveredResourceCounts",
      "config:ListDiscoveredResources",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVolumes",
      "ecs:DescribeClusters",
      "ecs:DescribeContainerInstances",
      "ecs:DescribeTaskDefinition",
      "ecs:ListClusters",
      "ecs:ListContainerInstances",
      "ecs:ListTaskDefinitions",
      "eks:DescribeCluster",
      "eks:ListClusters",
      "iam:Get*",
      "iam:List*",
      "lambda:GetFunction",
      "lambda:ListFunctions",
      "lightsail:GetInstances",
      "lightsail:GetRegions",
      "organizations:DescribeOrganization",
      "organizations:ListAccounts",
      "rds:DescribeDBInstances",
      "rds:ListTagsForResource",
      "s3:ListAllMyBuckets",
      "s3:GetBucketNotification",
      "s3:GetEncryptionConfiguration"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

# For existing trail with cross-account resources, deploy the expel role in log bucket account
resource "aws_iam_role_policy_attachment" "log_bucket_role_policy_attachment" {
  count      = var.is_existing_cloudtrail_cross_account ? 1 : 0
  depends_on = [aws_cloudformation_stack_set_instance.permeate_account_policy]
  provider   = aws.log_bucket
  role       = var.expel_assume_role_name
  policy_arn = aws_iam_policy.log_bucket_iam_policy[0].arn
}

resource "aws_iam_policy" "log_bucket_iam_policy" {
  count    = var.is_existing_cloudtrail_cross_account ? 1 : 0
  provider = aws.log_bucket
  name     = "${var.prefix}-log-bucket-policy"
  policy   = data.aws_iam_policy_document.log_bucket_iam_document.json

  tags = local.tags
}

# ignoring as these policies enable necessary observability on all AWS resources
# tfsec:ignore:aws-iam-no-policy-wildcards
data "aws_iam_policy_document" "log_bucket_iam_document" {
  # Allow Expel Workbench to get objects from cloudtrail bucket
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${local.cloudtrail_bucket_arn}/*"]
    effect    = "Allow"
  }

  # Allow Expel Workbench to receive and delete SQS messages
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [aws_sqs_queue.cloudtrail_queue.arn]
    effect    = "Allow"
  }

  # Allow Expel Workbench to decrypt cloudtrail bucket
  dynamic "statement" {
    for_each = var.existing_cloudtrail_kms_key_arn == null ? [] : [1]
    content {
      actions   = ["kms:Decrypt"]
      resources = [var.existing_cloudtrail_kms_key_arn]
      effect    = "Allow"
    }
  }

  # Allow Expel Workbench to decrypt notifications
  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.notification_encryption_key.arn]
    effect    = "Allow"
  }
}
