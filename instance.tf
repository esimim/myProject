resource "aws_instance" "myProject-Ec2" {
  ami           = lookup(var.AMIS, var.MY_AWS_REGION)
  #ami           = var.AMIS[var.MY_AWS_REGION]
  instance_type = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.myProject-public.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allowIn.id]

  # the public SSH key
  key_name = aws_key_pair.myProject.key_name
}

output "ip" {
  value = aws_instance.myProject-Ec2.public_ip
}
