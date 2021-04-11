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

  provisioner "local-exec" {
    #command = "sed 's/MYPROJECTELASTICSEARCHADDRESS/${aws_elasticsearch_domain.es-myproject.endpoint}/g' filebeat > filebeat.yml"
    command = "sed 's/$SEARCH/$REPLACE/g' filebeat > filebeatTemp"

    environment = {
      SEARCH = "MYPROJECTELASTICSEARCHADDRESS"
      REPLACE = aws_elasticsearch_domain.es-myproject.endpoint
    }
  }

  provisioner "local-exec" {
    #command = "sed 's/MYPROJECTKIBANAADDRESS/${aws_elasticsearch_domain.es-myproject.endpoint}/g' filebeat > filebeat.yml"
    command = "sed 's/$SEARCH/$REPLACE/g' filebeatTemp > filebeat.yml"

    environment = {
      SEARCH = "MYPROJECTKIBANAADDRESS"
      REPLACE = aws_elasticsearch_domain.es-myproject.kibana_endpoint
    }
  }

  # copies the filebeat.yml to /etc/filebeat/filebeat.yml
  provisioner "file" {
    destination = "/etc/filebeat/filebeat.yml"
    source      = "./filebeat.yml"
  }
}

output "ip" {
  value = aws_instance.myProject-Ec2.public_ip
}
