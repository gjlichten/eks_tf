provider "aws" {
  region  = "us-west-2"
  profile = "default"
}


locals {
  environment_name = "development"
  team             = "dtc"
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Environment = local.environment_name
    Team        = local.team
  }
}


module "istream_eks" {
  source              = "/modules/istream_eks"
  cluster-name        = "test"
  vpc_cidr            = "10.55.0.0/16"
  kube_admin_role_arn = "arn:aws:iam::829652485116:role/test-cluster-admin"
  common_tags         = local.common_tags
}

output "config-map-aws-auth" {
  value = "${module.istream_eks.config-map-aws-auth}"
}
