resource "aws_vpc" "livechat-vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.livechat-vpc.id
}

resource "aws_subnet" "public_a" {
  vpc_id     = aws_vpc.livechat-vpc.id
  cidr_block = var.public_subnet_a_cidr
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "public_b" {
  vpc_id     = aws_vpc.livechat-vpc.id
  cidr_block = var.public_subnet_b_cidr
  map_public_ip_on_launch = true
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.livechat-vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "${var.region}a"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.livechat-vpc.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

