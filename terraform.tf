terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
      # For new & existing cloudtrail with resources in single aws account, set the log_bucket alias to default aws provider.
      # For existing cloudtrail with resources in different aws accounts, create an aws provider for the log_bucket account & pass it's alias.
      # See examples for reference.
      configuration_aliases = [aws.log_bucket]
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.3"
    }
  }
  required_version = ">= 1.1.0"
}
