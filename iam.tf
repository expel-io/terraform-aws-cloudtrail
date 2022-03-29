resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.bucket
  policy = data.aws_iam_policy_document.cloudtrail_bucket_iam_document.json
}

data "aws_iam_policy_document" "cloudtrail_bucket_iam_document" {
  # Necessary to allow any bucket permissions
  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_bucket.arn]
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
      "${aws_s3_bucket.cloudtrail_bucket.arn}/*"
    ]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_sqs_queue_policy" "sqs_bucket_policy" {
  queue_url = aws_sqs_queue.cloudtrail_queue.id
  policy    = data.aws_iam_policy_document.sqs_bucket_iam_document.json
}

data "aws_iam_policy_document" "sqs_bucket_iam_document" {
  # Allow S3 to queue messages onto SQS
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.cloudtrail_queue.arn]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_iam_document" {
  # Allow Expel Workbench to decrypt cloudtrail bucket
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.expel_aws_account_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [var.expel_customer_organization_guid]
    }
  }
}

resource "aws_iam_role" "expel_assume_role" {
  name               = "ExpelServiceAssumeRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_iam_document.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cloudtrail_manager_role_policy_attachment" {
  role       = aws_iam_role.expel_assume_role.name
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
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.cloudtrail_bucket.arn}/*"]
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
  statement {
    actions   = ["kms:Decrypt"]
    resources = [aws_kms_key.cloudtrail_bucket_encryption_key.arn]
    effect    = "Allow"
  }

  # Allow Expel Workbench to gather information about AWS footprint
  statement {
    actions = [
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
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
      "organizations:ListAccounts",
      "rds:DescribeDBInstances",
      "rds:ListTagsForResource",
      "s3:ListAllMyBuckets"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
