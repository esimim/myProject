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
data "aws_subnet" "myprojectelk_public" {
  filter {
    name = "tag:Public"
    values = ["public-us-west-2a"]
  }
}

# get the 'myproject-vpc' vpc that this project uses
data "aws_vpc" "myprojectelk" {
  filter {
     name = "tag:Name"
     values = ["myprojectelk-vpc"]
  }
}

# defines the s3 backend
terraform {
  backend "s3" {
    bucket         = "terraform-state-myprojectelk"
    key            = "ec2/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks-myprojectelk"
    encrypt        = true
  }
}

# ec2 security group
resource "aws_security_group" "allow_in" {
  vpc_id      = data.aws_vpc.myprojectelk.id
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
resource "aws_key_pair" "myprojectelk_key" {
  key_name   = "myprojectelk-key"
  public_key = file(var.MY_PUBLIC_KEY)
}

# 
#resource "aws_iam_instance_profile" "myproject_ec2_profile" {
#  name = "myproject-ec2-profile"
#  role = data.aws_iam_role.get_post_config_role.name
  #role = date.aws_iam_role.role.name
#}

# create ec2 instance
resource "aws_instance" "myproject_ec2" {
  ami            = data.aws_ami.myproject_beats_ami.id
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = data.aws_subnet.myprojectelk_public.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow_in.id]

  # the public SSH key
  key_name = aws_key_pair.myprojectelk_key.key_name

}
