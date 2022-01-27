// Cloudtrail bucket policy
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.bucket
  policy = data.aws_iam_policy_document.cloudtrail_bucket_iam_document.json
}

data "aws_iam_policy_document" "cloudtrail_bucket_iam_document" {
  statement {
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_bucket.arn]
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
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
