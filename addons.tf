# When "aws_eks_addon" Terraform resources are destroyed the corresponding AWS
# EKS add-on is deleted and the component the add-on manages will be removed
# from the cluster. ALL Kubernetes resources for the component will be removed,
# including resources that were configured outside of AWS EKS add-ons. This
# includes pre add-on EKS resources, resources that were manually configured
# with kubectl, etc. Needless to say, removing a critical component like
# CoreDNS or the AWS CNI can seriously impact the workloads on the cluster.
#
# The behavior of the "aws_eks_addon" Terraform resource is especially
# problematic if an add-on installation fails because Terraform will delete 
# and recreate the resource on the next Terraform apply. This will result 
# in the component being removed from the cluster when the existing add-on
# is deleted. To prevent this behavior all "aws_eks_addons" in this module
# have Terraform lifecycle option "prevent_destroy" enabled.
#
# If a "aws_eks_addon" Terraform resource needs to be destroyed but the
# component it manages needs to remain in place, consider removing the AWS EKS
# add-on manually with the "Preserve on cluster" option. This option will
# prevent the removal of the component.
#
# For information on customizing AWS EKS add-on configuration, see:
# https://docs.aws.amazon.com/eks/latest/userguide/add-ons-configuration.html

resource "aws_eks_addon" "cni" {
  count = var.addons ? 1 : 0

  cluster_name             = aws_eks_cluster.cluster.name
  addon_name               = "vpc-cni"
  addon_version            = var.cni_addon_version
  service_account_role_arn = var.cni_addon_service_account_role_arn
  resolve_conflicts        = "OVERWRITE"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eks_addon" "coredns" {
  count = var.addons ? 1 : 0

  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "coredns"
  addon_version     = var.coredns_addon_version
  resolve_conflicts = "OVERWRITE"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eks_addon" "kube-proxy" {
  count = var.addons ? 1 : 0

  cluster_name      = aws_eks_cluster.cluster.name
  addon_name        = "kube-proxy"
  addon_version     = var.kubeproxy_addon_version
  resolve_conflicts = "OVERWRITE"

  lifecycle {
    prevent_destroy = true
  }
}
