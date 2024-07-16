data "aws_availability_zones" "default" {
  state = "available"
}

locals {
  availability_zones_names = data.aws_availability_zones.default.names
  availability_zones_map = {
    for idx, az in data.aws_availability_zones.default.names : az => idx + 1
  }
  public_subnets_ids = [for s in aws_subnet.public : s.id]
}

# Production VPC
resource "aws_vpc" "default" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  for_each = toset(data.aws_availability_zones.default.names)

  vpc_id            = aws_vpc.default.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr_block, 8, index(data.aws_availability_zones.default.names, each.key))

  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}-public-${local.availability_zones_map[each.key]}"
  }
}

resource "aws_subnet" "private" {
  for_each = toset(data.aws_availability_zones.default.names)

  vpc_id            = aws_vpc.default.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.cidr_block, 8, length(local.availability_zones_names) + index(local.availability_zones_names, each.key))

  tags = {
    Name = "${local.name}-private-${local.availability_zones_map[each.key]}"
  }
}


# Route tables for the subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.name}-public"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "${local.name}-private"
  }
}
#
## Associate the newly created route tables to the subnets
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  route_table_id = aws_route_table.public.id
  subnet_id      = each.value.id

}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  route_table_id = aws_route_table.private.id
  subnet_id      = each.value.id
}
#
## Elastic IP
resource "aws_eip" "nat_gateway" {
  domain = "vpc"
  #associate_with_private_ip = "10.0.0.5"
  depends_on = [aws_internet_gateway.default]
}
#
# NAT gateway
resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public[local.availability_zones_names[0]].id
  depends_on    = [aws_eip.nat_gateway]
}
resource "aws_route" "nat_gateway" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}
#
## Internet Gateway for the public subnet
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}
#
## Route the public subnet traffic through the Internet Gateway
resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}
