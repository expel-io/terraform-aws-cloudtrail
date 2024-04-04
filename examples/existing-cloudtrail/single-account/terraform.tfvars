/**
* This file contains the variable values for setting up an existing CloudTrail in a single AWS account.
* region: The AWS region in which you want the notification queue for CloudTrail to be set up.
* expel_customer_organization_guid: Your organization GUID assigned to you by Expel. You can find it in your browser URL after navigating to Settings > My Organization in Workbench.
* existing_cloudtrail_bucket_name: The name of your existing AWS S3 Bucket where CloudTrail logs are stored.
* existing_cloudtrail_kms_key_arn: The KMS Key ARN used for your CloudTrail S3 Bucket.
* existing_sns_topic_arn: The AWS SNS Topic ARN.
*/
region                           = "Replace with the AWS region in which you want the notification queue for CloudTrail to be set up"
expel_customer_organization_guid = "Replace with your organization GUID assigned to you by Expel."
existing_cloudtrail_kms_key_arn  = "Replace with the KMS Key ARN used for your CloudTrail S3 Bucket"
existing_sns_topic_arn           = "Replace with your AWS SNS Topic ARN"
