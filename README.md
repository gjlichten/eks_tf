## Description

Terraform module responsible for creating and managing the foundations of
and EKS cluster.  Secure and default configurations for VPC, IAM,
EKS cluster authentication, and Logging are provided.


**EKS / Kubernetes Features**
* Configurable EKS versions
* [EKS Control Plane Logging][1]
* [IAM based cluster authentication][2]
* Common Tags for resources


[1]: https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html
[2]: https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html

## Versions

There are 2 versions of this module in active support/development. See [releases](https://github.com/iStreamPlanet/istream_eks/releases) tab for the latest available version.

- v3.x, which is tracked by the [default branch](https://github.com/iStreamPlanet/istream_eks)
- v2.x, which is tracked by the [`v2` branch](https://github.com/iStreamPlanet/istream_eks/tree/v2)

## VPC Details
```
Supernet:        `"10.0.0.0/16"`            ## Configurable VPC Supernet
Secondary CIDR:  `"100.64.0.0/16"`          ## Configurable Secondary CIDR
Subnets (count): `3` (`zone_count`)         ## Span 3 Availability Zones
```
|Name|Ranges|IPs|CIDR Calculation|
|--|--|--|--|
|`${cluster}-public`|`10.0.{0,8,16}.0`|2046 (`/21`)|`cidrsubnet(cidr, 5, count.index)`|
|`${cluster}-private`|`10.0.{32,64,96}.0`|8190 (`/19`)|`cidrsubnet(cidr, 5, count.index + 1)`|
|`${cluster}-data`|`10.0.{144,146,148}.0`|510 (`/23`)|`cidrsubnet(cidr, 7, count.index + 72)`|
|`${cluster}-cgnat`|`100.64.{0,32,64}.0`|8190 (`/19`)|`cidrsubnet(cidr, 3, count.index + 0)`|

##### `${cluster}-public`
* Internet traffic: Internet Gateway
* Usage: Public Load Balancers, EC2 Instances

##### `${cluster}-private`
* Internet traffic: NAT Gateway
* Usage: Private Load Balancers, EC2 Instances

##### `${cluster}-data`
* Internet traffic: Not Available.  Internal resources only
* Usage: Data-layer (ElastiCache, RDS, etc.)

##### `${cluster}-cgnat`
* Pod Networking on Shared IP Space (RFC6598)


## Usage

The repository contains an [`/example`](/example) folder with a `Makefile`
for usage.

```
$ make shell
$ terraform init
$ terraform plan
$ terraform apply
```

See [USAGE.md](USAGE.md) for full module documentation.
