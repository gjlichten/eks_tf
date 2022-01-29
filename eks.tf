locals {
  aws_root_ca_fingerprint = lower("9e99a48a9960b14926bb7f3b02e22da2b0ab7280")
}

resource "aws_eks_cluster" "cluster" {

  name                      = var.cluster-name
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = var.cluster_log_types
  version                   = var.kubernetes_version
  tags                      = var.common_tags

  vpc_config {
    security_group_ids      = [aws_security_group.cluster.id]
    subnet_ids              = aws_subnet.cluster-private.*.id
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.cluster-logs
  ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster-name
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.aws_root_ca_fingerprint]
  url             = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_cloudwatch_log_group" "cluster-logs" {
  name              = "/aws/eks/${var.cluster-name}/cluster"
  retention_in_days = var.cluster_log_retention_days
}
