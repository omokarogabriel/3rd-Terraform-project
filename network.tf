#This comprises of vpc,subnets,gateways(igw,ngw), route tables, security groups
#This is a module to create a VPC with public and private subnets, internet gateway, NAT gateway, route tables, and security groups.

#vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.project}-vpc"
    Environment = var.environment
  }
}
#public subnets
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  # map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
  }
}
#private subnets
resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name        = "${var.project}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private"
  }
}
#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project}-igw"
    Environment = var.environment
  }
}
#nat gateway
resource "aws_eip" "nat_eip" {
  # vpc = true
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name        = "${var.project}-nat-gw"
    Environment = var.environment
  }
}
#route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project}-public-route-table"
    Environment = var.environment
  }
}
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  depends_on             = [aws_internet_gateway.igw]
}
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}
#route table for private subnets 
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project}-private-route-table"
    Environment = var.environment
  }
}
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
  depends_on             = [aws_nat_gateway.nat_gw]
}
resource "aws_route_table_association" "private_subnet_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = element(aws_subnet.private_subnet[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

