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
                "RoleName": "ExpelRoleTF",
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
                "ManagedPolicyName": "ExpelAccessPolicyTF",
                "PolicyDocument": {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Action": [
                                "ec2:DescribeInstances",
                                "ec2:DescribeRegions",
                                "ec2:DescribeSecurityGroups",
                                "iam:List*",
                                "iam:Get*",
                                "rds:DescribeDBInstances",
                                "rds:ListTagsForResource",
                                "organizations:ListAccounts",
                                "ec2:DescribeVolumes",
                                "ecs:DescribeTaskDefinition",
                                "ecs:ListTaskDefinitions",
                                "lambda:GetFunction",
                                "lambda:ListFunctions",
                                "lightsail:GetInstances",
                                "lightsail:GetRegions",
                                "s3:ListAllMyBuckets",
                                "cloudtrail:GetTrailStatus",
                                "cloudtrail:DescribeTrails",
                                "config:ListDiscoveredResources",
                                "config:GetDiscoveredResourceCounts",
                                "eks:DescribeCluster",
                                "eks:ListClusters",
                                "ecs:ListContainerInstances",
                                "ecs:DescribeContainerInstances",
                                "ecs:DescribeClusters",
                                "ecs:ListClusters"
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
