locals {
  name                       = "myproject"
  region                     = "us-east-1"
  azs                        = ["${local.region}a", "${local.region}b", "${local.region}c"]

  tags = {
    Project     = local.name
    Environment = terraform.workspace
  }
}

# defines the s3 backend
terraform {
  backend "s3" {
    bucket         = "terraform-state-myproject"
    key            = "elasticsearch/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-myproject"
    encrypt        = true
  }
}

data "aws_region" "current" {}

# Internet VPC
resource "aws_vpc" "myproject" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "myproject-vpc"
  }
}

# Internet GW
resource "aws_internet_gateway" "myproject_gw" {
  vpc_id = aws_vpc.myproject.id

  tags = {
    Name = "myproject-gw"
  }
}

# route table
resource "aws_route_table" "myproject_public" {
  vpc_id = aws_vpc.myproject.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myproject_gw.id
  }

  tags = {
    Name = "myproject-public-route"
  }
}

# Public Subnets
resource "aws_subnet" "myproject_public" {
  count                   = length(local.azs)
  vpc_id                  = aws_vpc.myproject.id
  availability_zone       = local.azs[count.index]
  cidr_block              = cidrsubnet(aws_vpc.myproject.cidr_block, 8, count.index)
  map_public_ip_on_launch = "true"

  tags = merge(local.tags, {
    Name = "${local.name}-public"
    Public = "public-${local.azs[count.index]}"
  })
}

# route association public
resource "aws_route_table_association" "myproject_public" {
  count          = length(local.azs)
  subnet_id      = aws_subnet.myproject_public[count.index].id
  route_table_id = aws_route_table.myproject_public.id
}

# Private Subnets
resource "aws_subnet" "myproject_private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.myproject.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(aws_vpc.myproject.cidr_block, 8, count.index + length(local.azs))

  tags = merge(local.tags, {
    Name = "${local.name}-private"
    Private = "private-${local.azs[count.index]}"
  })
}

resource "aws_security_group" "es" {
  name = "myprojectes-sg"
  description = "Allow inbound traffic to ElasticSearch from VPC CIDR"
  vpc_id = aws_vpc.myproject.id

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
          aws_vpc.myproject.cidr_block
      ]
  }
}

resource "aws_iam_service_linked_role" "myproject_es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain" "myproject_es" {
  domain_name = "myproject-es"
  elasticsearch_version = "7.9"

  cluster_config {
      instance_count = 3
      instance_type = "t2.small.elasticsearch"
      zone_awareness_enabled = true

      zone_awareness_config {
        availability_zone_count = 3
      }
  }

  vpc_options {
      subnet_ids = aws_subnet.myproject_private[*].id
      security_group_ids = [
          aws_security_group.es.id
      ]
  }

  ebs_options {
      ebs_enabled = true
      volume_size = 10
  }
  access_policies = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/myproject-es/*",
      "Condition": {
        "IpAddress": {"aws:SourceIp": ["66.193.100.22/32"]}
      }
    }
  ]
}
POLICY

  snapshot_options {
      automated_snapshot_start_hour = 23
  }

  tags = {
      Domain = "myproject-es"
  }

  provisioner "local-exec" {
    command = "sed 's/${var.elasticaddressfield}/${aws_elasticsearch_domain.myproject_elastic.endpoint}/g' filebeat > filebeatTemp"
  }

  provisioner "local-exec" {
    command = "sed 's/${var.kibanaaddressfield}/${aws_elasticsearch_domain.myproject_elastic.endpoint}/g' filebeatTemp > ../packer/filebeat.yml"
  }
}
