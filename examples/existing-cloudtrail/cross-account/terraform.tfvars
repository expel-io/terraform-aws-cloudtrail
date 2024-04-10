# This file contains the variable values for setting up an existing CloudTrail 
# with cross-account notifications.
# 
# Replace the placeholder values with the appropriate values for 
# your environment.

region                                    = "Replace with the AWS region in which you want the notification queue for CloudTrail to be set up"
expel_customer_organization_guid          = "Replace with your organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench"
existing_cloudtrail_bucket_name           = "Replace with your AWS S3 Bucket name"
aws_management_account_id                 = "Replace with your AWS Management account id"
existing_cloudtrail_log_bucket_account_id = "Replace with your AWS Cloudtrail log bucket account id"
existing_cloudtrail_kms_key_arn           = "Replace with the KMS Key ARN used for your CloudTrail S3 Bucket"
existing_sns_topic_arn                    = "Replace with your AWS SNS Topic ARN"
