# find the latest ami built from Packer
data "aws_ami" "myproject_beats_ami" {
  most_recent = true

  owners = ["self"]
  tags = {
    Name   = "myproject-beats-ami"
    Beats  = "true"
  }
}

# get the us-east-1a public subnet
data "aws_subnet" "myproject_public" {
  filter {
    name = "tag:Public"
    values = ["public-us-east-1a"]
  }
}

# get the 'myproject-vpc' vpc that this project uses
data "aws_vpc" "myproject" {
  filter {
     name = "tag:Name"
     values = ["myproject-vpc"]
  }
}

# get the aws_iam_role for configuring ec2
data "aws_iam_role" "get_post_config_role" {
  name = "get-post-config-role"
}

# defines the s3 backend
terraform {
  backend "s3" {
    bucket         = "terraform-state-myproject"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks-myproject"
    encrypt        = true
  }
}

# ec2 security group
resource "aws_security_group" "allow_in" {
  vpc_id      = data.aws_vpc.myproject.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"

  tags = {
    Name = "allow-in"
  }
}

# ec2 security group rule: allow HTTPS
resource "aws_security_group_rule" "allowHTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_in.id
}

# ec2 security group rule: allow ssh
resource "aws_security_group_rule" "allowSSH" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_in.id
}

# ec2 security group rule: allow egress
resource "aws_security_group_rule" "allowegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_in.id
}

# ec2 public key: allow ssh access
resource "aws_key_pair" "myproject_key" {
  key_name   = "myproject-key"
  public_key = file(var.MY_PUBLIC_KEY)
}

# 
resource "aws_iam_instance_profile" "myproject_ec2_profile" {
  name = "myproject-ec2-profile"
  role = data.aws_iam_role.get_post_config_role.name
  #role = date.aws_iam_role.role.name
}

# create ec2 instance
resource "aws_instance" "myproject_ec2" {
  ami            = data.aws_ami.myproject_beats_ami.id
  #ami           = lookup(var.AMIS, var.MY_AWS_REGION)
  #ami           = var.AMIS[var.MY_AWS_REGION]
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = data.aws_subnet.myproject_public.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow_in.id]

  # the public SSH key
  key_name = aws_key_pair.myproject_key.key_name

  iam_instance_profile = aws_iam_instance_profile.myproject_ec2_profile.name

}

