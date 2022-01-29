#
# Outputs
#

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: ${var.kube_admin_role_arn}
      username: kube_admin:{{SessionName}}
      groups:
        - system:masters
CONFIGMAPAWSAUTH

  userdata = <<USERDATADOC
#!/bin/bash -xe
B64_CLUSTER_CA=${aws_eks_cluster.cluster.certificate_authority.0.data}
API_SERVER_URL=${aws_eks_cluster.cluster.endpoint}
/etc/eks/bootstrap.sh ${var.cluster-name} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL %{if var.kubelet_extra_args != ""}--kubelet-extra-args '${var.kubelet_extra_args}' %{endif}
USERDATADOC

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: ${var.cluster-name}
contexts:
- context:
    cluster: ${var.cluster-name}
    user: ${var.cluster-name}
  name: ${var.cluster-name}
current-context: ${var.cluster-name}
kind: Config
preferences: {}
users:
- name: ${var.cluster-name}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - "eks"
        - "get-token"
        - "--cluster-name"
        - ${var.cluster-name}
        - "--role"
        - ${var.kube_admin_role_arn}
KUBECONFIG

  worker_subnet = var.public_subnet_topology ? aws_subnet.cluster : aws_subnet.cluster-private
}

output "eks_cluster" {
  value       = aws_eks_cluster.cluster
  description = "The EKS cluster to be created"
}

output "eks_cluster_token" {
  value       = data.aws_eks_cluster_auth.cluster.token
  description = "An IAM token to use for the Kubernetes provider"
}

output "eks_cluster_oidc_arn" {
  value       = aws_iam_openid_connect_provider.cluster.arn
  description = "The OIDC role ARN created for this cluster"
}

output "eks_worker_arn" {
  value       = aws_iam_role.node.arn
  description = "The role arn for the EKS workers"
}

output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.cluster.endpoint
  description = "Host for the cluster api servers"
}

output "eks_ca" {
  value       = aws_eks_cluster.cluster.certificate_authority.0.data
  description = "Cluster certificate authority data"
}

output "config-map-aws-auth" {
  value       = local.config-map-aws-auth
  description = "The `aws-auth` ConfigMap used to authenticate users and systems."
}

output "kubeconfig" {
  value       = local.kubeconfig
  description = "The kubeconfig to communicate with the cluster"
}

output "userdata" {
  value       = local.userdata
  description = "EC2 `userdata` to apply use with EC2 instances that are being bootstrapped into "
}

output "eks_vpc_id" {
  value       = aws_vpc.cluster.id
  description = "VPC ID of the cluster."
}

output "public_route_table" {
  value       = aws_route_table.cluster
  description = "The route table for our public records"
}

output "private_route_table" {
  value       = aws_route_table.cluster-private
  description = "The route table for our private records"
}

output "data_route_table" {
  value       = aws_route_table.cluster-data
  description = "The route table for our data records"
}

# Used for filtering for the appropriate aws_ami
output "cluster_version" {
  value       = aws_eks_cluster.cluster.version
  description = "The version of the cluster"
}

# Used for the launch configuration for worker nodes
output "instance_profile_name" {
  value       = aws_iam_instance_profile.node.name
  description = "The instance profile"
}

# Used for the launch configuration for worker nodes
output "worker_security_group" {
  value       = aws_security_group.node.id
  description = "The security group for the workers"
}

# Used for a subnet with possibility of both public ingress and egress
output "public_subnet" {
  value       = aws_subnet.cluster
  description = "A public subnet for public ingress/egress"
}

# Used for a subnet with public egress but not public ingress
output "private_subnet" {
  value       = aws_subnet.cluster-private
  description = "A private subnet for egress only traffic"
}

output "data_subnet" {
  value       = aws_subnet.cluster-data
  description = "A private subnet for databases, caches, etc."
}

output "worker_subnet" {
  value       = local.worker_subnet
  description = "Subnet for EKS worker nodes"
}

# Used for a subnet with CGNAT for EKS Pods
output "cgnat_subnet" {
  value       = aws_subnet.cluster-cgnat
  description = "A subnet for pod networking"
}
