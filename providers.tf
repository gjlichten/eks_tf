# Terraform Configuration.
# Requiring the latest versions from the time of initial module development.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.48.0"
    }
  }

  required_version = ">= 0.14.11"
}

# Provide generic configuration for any region.

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}
