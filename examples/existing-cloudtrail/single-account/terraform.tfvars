# This file contains the variable values for setting up an existing CloudTrail in a single AWS account.
#
# Replace the placeholder values with the appropriate values for
# your environment.

region                           = "Replace with the AWS region in which you want the notification queue for CloudTrail to be set up"
expel_customer_organization_guid = "Replace with your organization GUID assigned to you by Expel."
existing_cloudtrail_bucket_name  = "Replace with your AWS S3 Bucket name"
existing_cloudtrail_kms_key_arn  = "Replace with the KMS Key ARN used for your CloudTrail S3 Bucket"
existing_sns_topic_arn           = "Replace with your AWS SNS Topic ARN"
