#
# VPC Resources
#  * VPC
#  * EIP for NAT Gateway
#  * Subnets
#  * NAT Gateway
#  * Internet Gateway
#  * Route Table
#

locals {
  vpc-name             = var.vpc-name == "" ? var.cluster-name : var.vpc-name
  private_subnet_count = var.public_subnet_topology ? 0 : var.zone_count
  public_subnet_count  = var.private_subnet_topology ? 0 : var.zone_count
  cgnat_subnet_count   = var.zone_count
  data_subnet_count    = var.zone_count
}


## VPC Resource
resource "aws_vpc" "cluster" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.dns_hostnames

  tags = merge(var.common_tags,
    {
      "Name"                                      = "${local.vpc-name}-eks-vpc"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = aws_vpc.cluster.id
  cidr_block = var.secondary_cidr
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.cluster.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
}


resource "aws_vpc_endpoint" "ec2-api" {
  vpc_id              = aws_vpc.cluster.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  subnet_ids          = concat(aws_subnet.cluster-private.*.id)

  security_group_ids = [
    aws_security_group.node.id
  ]
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.cluster.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  subnet_ids          = concat(aws_subnet.cluster-private.*.id)

  security_group_ids = [
    aws_security_group.node.id
  ]
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = aws_vpc.cluster.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  private_dns_enabled = true
  vpc_endpoint_type   = "Interface"
  subnet_ids          = concat(aws_subnet.cluster-private.*.id)

  security_group_ids = [
    aws_security_group.node.id
  ]
}

## EIPs for for NAT
resource "aws_eip" "nat" {
  count = local.private_subnet_count
  vpc   = true

  tags = merge(var.common_tags,
    {
      "Name" = "${var.cluster-name}-nat"
    }
  )
}


resource "aws_subnet" "cluster" {
  count             = local.public_subnet_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, var.cluster_public_cidr_newbits, count.index + var.cluster_public_network_selector)
  vpc_id            = aws_vpc.cluster.id

  map_public_ip_on_launch = true

  tags = merge(var.common_tags,
    {
      "Name"                                      = "${var.cluster-name}-public"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
      "kubernetes.io/role/elb"                    = "1"
    }
  )
}

resource "aws_subnet" "cluster-private" {
  count             = local.private_subnet_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, var.cluster_private_cidr_newbits, count.index + var.cluster_private_network_selector)
  vpc_id            = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name"                                      = "${var.cluster-name}-private"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

resource "aws_subnet" "cluster-data" {
  count             = local.data_subnet_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, var.cluster_data_cidr_newbits, count.index + var.cluster_data_network_selector)
  vpc_id            = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name"                                      = "${var.cluster-name}-data"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
  )
}

resource "aws_subnet" "cluster-cgnat" {
  count             = local.cgnat_subnet_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.secondary_cidr, var.cluster_cgnat_cidr_newbits, count.index + var.cluster_cgnat_network_selector)
  vpc_id            = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name"                                      = "${var.cluster-name}-cgnat"
      "kubernetes.io/cluster/${var.cluster-name}" = "shared"
    }
  )
}


resource "aws_nat_gateway" "gw" {
  count         = local.public_subnet_count
  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id     = aws_subnet.cluster.*.id[count.index]

  tags = merge(var.common_tags,
    {
      "Name" = var.cluster-name
    }
  )
}

resource "aws_internet_gateway" "cluster" {
  vpc_id = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name" = "${var.cluster-name}-ig"
    }
  )
}

resource "aws_route_table" "cluster" {
  vpc_id = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name" = "${var.cluster-name}-public"
    }
  )
}

resource "aws_route" "cluster" {
  route_table_id         = aws_route_table.cluster.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cluster.id
}

resource "aws_route_table" "cluster-cgnat" {
  count  = local.cgnat_subnet_count
  vpc_id = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name" = "${var.cluster-name}-cgnat"
    }
  )
}

resource "aws_route" "cluster-cgnat" {
  count                  = local.cgnat_subnet_count
  route_table_id         = aws_route_table.cluster-cgnat.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.*.id[count.index]
}


resource "aws_route_table" "cluster-data" {
  vpc_id = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name" = "${var.cluster-name}-data"
    }
  )
}

resource "aws_route_table" "cluster-private" {
  count  = local.private_subnet_count
  vpc_id = aws_vpc.cluster.id

  tags = merge(var.common_tags,
    {
      "Name" = "${var.cluster-name}-private"
    }
  )
}

resource "aws_route" "cluster-private" {
  count                  = local.private_subnet_count
  route_table_id         = aws_route_table.cluster-private.*.id[count.index]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.*.id[count.index]
}

resource "aws_route_table_association" "cluster" {
  count          = local.public_subnet_count
  subnet_id      = aws_subnet.cluster.*.id[count.index]
  route_table_id = aws_route_table.cluster.id
}

resource "aws_vpc_endpoint_route_table_association" "cluster" {
  count           = local.public_subnet_count
  route_table_id  = aws_route_table.cluster.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_route_table_association" "cluster-private" {
  count          = local.private_subnet_count
  subnet_id      = aws_subnet.cluster-private.*.id[count.index]
  route_table_id = aws_route_table.cluster-private.*.id[count.index]
}

resource "aws_vpc_endpoint_route_table_association" "cluster-private" {
  count           = local.private_subnet_count
  route_table_id  = aws_route_table.cluster-private.*.id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_route_table_association" "cluster-data" {
  count          = local.data_subnet_count
  subnet_id      = aws_subnet.cluster-data.*.id[count.index]
  route_table_id = aws_route_table.cluster-data.id
}

resource "aws_vpc_endpoint_route_table_association" "cluster-data" {
  count           = local.data_subnet_count
  route_table_id  = aws_route_table.cluster-data.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_route_table_association" "cluster-cgnat" {
  count          = local.cgnat_subnet_count
  subnet_id      = aws_subnet.cluster-cgnat.*.id[count.index]
  route_table_id = aws_route_table.cluster-cgnat.*.id[count.index]
}

resource "aws_vpc_endpoint_route_table_association" "cluster-cgnat" {
  count           = local.cgnat_subnet_count
  route_table_id  = aws_route_table.cluster-cgnat.*.id[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
