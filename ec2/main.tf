data "terraform_remote_state" "elasticsearch" {
  backend = "local"

  config = {
    path = "../elasticsearch/terraform.tfstate"
  }
}

data "aws_ami" "myproject_beats_ami" {
  most_recent = true

  owners = ["self"]
  tags = {
    Name   = "myproject-beats-ami"
    Beats  = "true"
  }
}

data "aws_subnet" "myproject_public" {
  filter {
    name = "tag:Public"
    values = ["public-us-east-1a"]
  }
}

data "aws_vpc" "myproject" {
  filter {
     name = "tag:Name"
     values = ["myproject-vpc"]
  }
}

resource "aws_security_group" "allow_in" {
  vpc_id      = data.aws_vpc.myproject.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"

  tags = {
    Name = "allow-in"
  }
}

resource "aws_security_group_rule" "allowHTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_in.id
}

resource "aws_security_group_rule" "allowSSH" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_in.id
}

resource "aws_security_group_rule" "allowegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_in.id
}

resource "aws_key_pair" "myproject_key" {
  key_name   = "myproject-key"
  public_key = file(var.MY_PUBLIC_KEY)
}

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

}
