## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.8 |
| aws | >= 2.27.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.27.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_iam\_permissions\_boundary | AWS permission boundary used with the AWS Provider. | `string` | `""` | no |
| cluster-name | Unique name for the cluster. | `string` | n/a | yes |
| cluster\_cgnat\_cidr\_newbits | The number of additional bits with which to extend the prefix for secondary\_cidr (CGNAT) IPs in the cluster. | `number` | `3` | no |
| cluster\_cgnat\_network\_selector | Modifier added to count.index to determine the subnet of the CIDR you want for the secondary\_cidr (CGNAT) cluster. Also knows as netnum for the cidrsubnet func. | `number` | `1` | no |
| cluster\_data\_cidr\_newbits | The number of additional bits with which to extend the prefix for data IPs in the cluster. | `number` | `7` | no |
| cluster\_data\_network\_selector | Modifier added to count.index to determine the subnet of the CIDR you want for the data cluster. Also knows as netnum for the cidrsubnet func. | `number` | `72` | no |
| cluster\_log\_retention\_days | Number of days to retain EKS cluster logs. | `number` | `7` | no |
| cluster\_log\_types | Amazon EKS Control Plan Logging Components. | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| cluster\_private\_cidr\_newbits | The number of additional bits with which to extend the prefix for private IPs in the cluster. | `number` | `3` | no |
| cluster\_private\_network\_selector | Modifier added to count.index to determine the subnet of the CIDR you want for the private cluster. Also knows as netnum for the cidrsubnet func. | `number` | `1` | no |
| cluster\_public\_cidr\_newbits | The number of additional bits with which to extend the prefix for public IPs in the cluster. | `number` | `5` | no |
| cluster\_public\_network\_selector | Modifier added to count.index to determine the subnet of the CIDR you want for the public cluster. Also knows as netnum for the cidrsubnet func. | `number` | `0` | no |
| common\_tags | This is a map type for applying tags on resources. | `map` | `{}` | no |
| dns\_hostnames | Enable VPC DNS hostname resolution. | `bool` | `false` | no |
| kube\_admin\_role\_arn | ARN for a role that gets admin access to the Kubernetes cluster. | `string` | n/a | yes |
| kubelet\_extra\_args | --kubelet-extra-args support for UserData. | `string` | `""` | no |
| kubernetes\_version | Default EKS version to use. | `string` | `"1.16"` | no |
| private\_subnet\_topology | When true creates a VPC with only private subnets. Public subnets and NAT will not be created. | `bool` | `false` | no |
| public\_subnet\_topology | When true creates a VPC with only public and data subnets. Private subnets and NAT will not be created. | `bool` | `false` | no |
| secondary\_cidr | IPv4 Supernet for RFC6598. | `string` | `"100.64.0.0/16"` | no |
| vpc-name | Unique name for the VPC. If left unset, defaults to the cluster-name. | `string` | `""` | no |
| vpc\_cidr | IPv4 Supernet. | `string` | `"10.0.0.0/16"` | no |
| zone\_count | Number of Availability Zones | `number` | `3` | no |

## Outputs

| Name | Description |
|------|-------------|
| cgnat\_subnet | A subnet for pod networking |
| cluster\_version | The version of the cluster |
| config-map-aws-auth | The `aws-auth` ConfigMap used to authenticate users and systems. |
| data\_route\_table | The route table for our data records |
| data\_subnet | A private subnet for databases, caches, etc. |
| eks\_ca | Cluster certificate authority data |
| eks\_cluster | The EKS cluster to be created |
| eks\_cluster\_endpoint | Host for the cluster api servers |
| eks\_cluster\_oidc\_arn | The OIDC role ARN created for this cluster |
| eks\_cluster\_token | An IAM token to use for the Kubernetes provider |
| eks\_vpc\_id | VPC ID of the cluster. |
| eks\_worker\_arn | The role arn for the EKS workers |
| instance\_profile\_name | The instance profile |
| kubeconfig | The kubeconfig to communicate with the cluster |
| private\_route\_table | The route table for our private records |
| private\_subnet | A private subnet for egress only traffic |
| public\_route\_table | The route table for our public records |
| public\_subnet | A public subnet for public ingress/egress |
| userdata | EC2 `userdata` to apply use with EC2 instances that are being bootstrapped into |
| worker\_security\_group | The security group for the workers |
| worker\_subnet | Subnet for EKS worker nodes |

