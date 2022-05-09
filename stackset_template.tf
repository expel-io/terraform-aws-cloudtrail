locals {
  stackset_template = <<TEMPLATE
{
    "AWSTemplateFormatVersion": "2010-09-09",
    "Parameters" : {
        "ExpelCustomerOrganizationGUID" : {
            "Type" : "String"
        },
         "ExpelAssumeRoleARN" : {
            "Type" : "String"
        }
    },
    "Resources": {
        "IAMR7FYC": {
            "Type": "AWS::IAM::Role",
            "Properties": {
                "ManagedPolicyArns": [
                    {
                        "Ref": "IAMMP12SQ7"
                    }
                ],
                "RoleName": "ExpelRole",
                "AssumeRolePolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {
                                "AWS": { "Ref": "ExpelAssumeRoleARN" }
                            },
                            "Action": "sts:AssumeRole",
                            "Condition": {
                                "StringEquals": {
                                    "sts:ExternalId": { "Ref": "ExpelCustomerOrganizationGUID" }
                                }
                            }
                        }
                    ]
                }
            }
        },
        "IAMMP12SQ7": {
            "Type": "AWS::IAM::ManagedPolicy",
            "Properties": {
                "ManagedPolicyName": "ExpelAccessPolicy",
                "PolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Action": [
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
                            ],
                            "Resource": "*"
                        }
                    ]
                }
            }
        }
    }
}
TEMPLATE
}
