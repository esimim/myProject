# Internet VPC
resource "aws_vpc" "myProject" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "main"
  }
}

# Public Subnet
resource "aws_subnet" "myProject-public" {
  vpc_id                  = aws_vpc.myProject.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "myProject-public"
  }
}

# Private Subnet
resource "aws_subnet" "myProject-private" {
  vpc_id                  = aws_vpc.myProject.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "myProject-private"
  }
}

# Private Subnet
resource "aws_subnet" "myProject-private1" {
  vpc_id                  = aws_vpc.myProject.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "myProject-private1"
  }
}

# Private Subnet
resource "aws_subnet" "myProject-private2" {
  vpc_id                  = aws_vpc.myProject.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1c"

  tags = {
    Name = "myProject-private2"
  }
}

# Internet GW
resource "aws_internet_gateway" "myProject-gw" {
  vpc_id = aws_vpc.myProject.id

  tags = {
    Name = "myProject-gw"
  }
}

# route table
resource "aws_route_table" "myProject-public" {
  vpc_id = aws_vpc.myProject.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myProject-gw.id
  }

  tags = {
    Name = "myProject-public"
  }
}

# route association public
resource "aws_route_table_association" "myProject-public" {
  subnet_id      = aws_subnet.myProject-public.id
  route_table_id = aws_route_table.myProject-public.id
}
