resource "aws_security_group" "allowIn" {
  vpc_id      = aws_vpc.myProject.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_security_group_rule" "allowHTTPS" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allowIn.id
}

resource "aws_security_group_rule" "allowSSH" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allowIn.id
}

resource "aws_security_group_rule" "allowegress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allowIn.id
}

resource "aws_security_group" "es" {
  name = "myprojectes-sg"
  description = "Allow inbound traffic to ElasticSearch from VPC CIDR"
  vpc_id = aws_vpc.myProject.id

  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
          aws_vpc.myProject.cidr_block
      ]
  }
}