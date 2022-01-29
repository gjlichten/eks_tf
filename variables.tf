variable "cluster-name" {
  type        = string
  description = "Unique name for the cluster."
}

variable "vpc-name" {
  type        = string
  default     = ""
  description = "Unique name for the VPC. If left unset, defaults to the cluster-name."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "IPv4 Supernet."
}

variable "zone_count" {
  type        = number
  default     = 3
  description = "Number of Availability Zones"
}

variable "secondary_cidr" {
  type        = string
  default     = "100.64.0.0/16"
  description = "IPv4 Supernet for RFC6598."
}

variable "dns_hostnames" {
  type        = bool
  default     = false
  description = "Enable VPC DNS hostname resolution."
}

variable "kube_admin_role_arn" {
  type        = string
  description = "ARN for a role that gets admin access to the Kubernetes cluster."
}

variable "aws_iam_permissions_boundary" {
  type        = string
  default     = ""
  description = "AWS permission boundary used with the AWS Provider."
}

variable "cluster_log_types" {
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  description = "Amazon EKS Control Plan Logging Components."
}

variable "cluster_log_retention_days" {
  type        = number
  default     = 7
  description = "Number of days to retain EKS cluster logs."
}

variable "kubernetes_version" {
  type        = string
  default     = "1.16"
  description = "Default EKS version to use."
}

variable "common_tags" {
  description = "This is a map type for applying tags on resources."
  type        = map(any)
  default     = {}
}

variable "kubelet_extra_args" {
  description = "--kubelet-extra-args support for UserData."
  type        = string
  default     = ""
}

variable "public_subnet_topology" {
  type        = bool
  description = "When true creates a VPC with only public and data subnets. Private subnets and NAT will not be created."
  default     = false
}

variable "private_subnet_topology" {
  type        = bool
  description = "When true creates a VPC with only private subnets. Public subnets and NAT will not be created."
  default     = false
}

variable "cluster_public_cidr_newbits" {
  type        = number
  description = "The number of additional bits with which to extend the prefix for public IPs in the cluster."
  default     = 5
}

variable "cluster_private_cidr_newbits" {
  type        = number
  description = "The number of additional bits with which to extend the prefix for private IPs in the cluster."
  default     = 3
}

variable "cluster_data_cidr_newbits" {
  type        = number
  description = "The number of additional bits with which to extend the prefix for data IPs in the cluster."
  default     = 7
}

variable "cluster_cgnat_cidr_newbits" {
  type        = number
  description = "The number of additional bits with which to extend the prefix for secondary_cidr (CGNAT) IPs in the cluster."
  default     = 3
}

variable "cluster_public_network_selector" {
  type        = number
  description = "Modifier added to count.index to determine the subnet of the CIDR you want for the public cluster. Also knows as netnum for the cidrsubnet func."
  default     = 0
}

variable "cluster_private_network_selector" {
  type        = number
  description = "Modifier added to count.index to determine the subnet of the CIDR you want for the private cluster. Also knows as netnum for the cidrsubnet func."
  default     = 1
}

variable "cluster_data_network_selector" {
  type        = number
  description = "Modifier added to count.index to determine the subnet of the CIDR you want for the data cluster. Also knows as netnum for the cidrsubnet func."
  default     = 72
}

variable "cluster_cgnat_network_selector" {
  type        = number
  description = "Modifier added to count.index to determine the subnet of the CIDR you want for the secondary_cidr (CGNAT) cluster. Also knows as netnum for the cidrsubnet func."
  default     = 1
}

variable "addons" {
  type        = bool
  description = "When true creates AWS EKS Add-ons."
  default     = true
}

variable "cni_addon_version" {
  type        = string
  description = "AWS VPC CNI EKS addon version. If left unspecified AWS will provide a default based off of the cluster version."
  default     = null
}

variable "cni_addon_service_account_role_arn" {
  type        = string
  description = "ARN of IAM role used for CNI EKS add-on. If value is empty - then add-on uses the IAM role assigned to the EKS Cluster node."
  default     = null
}

variable "coredns_addon_version" {
  type        = string
  description = "coredns EKS addon version. If left unspecified AWS will provide a default based off of the cluster version."
  default     = null
}

variable "kubeproxy_addon_version" {
  type        = string
  description = "kube-proxy EKS addon version. If left unspecified AWS will provide a default based off of the cluster version."
  default     = null
}
