# If you don't set a default, then you will need to provide the variable
# at run time using the command line, or set it in the environment. For more
# information about the various options for setting variables, see the template
# [reference documentation](https://www.packer.io/docs/templates)
variable "ami_name" {
  type    = string
  default = "myprojectBeats-ami"
}

variable "myvpc_id" {
    type = string
}

variable "mysubnet_id" {
    type = string
}

variable "mysource_ami" {
    type = string
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

# source blocks configure your builder plugins; your source is then used inside
# build blocks to create resources. A build block runs provisioners and
# post-processors on an instance created by the source.
source "amazon-ebs" "myprojectImage" {
  ami_name      = "packer example ${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"
  ssh_username = "ec2-user"
  source_ami = "${var.mysource_ami}"
  vpc_id = "${var.myvpc_id}"
  subnet_id = "${var.mysubnet_id}"
}

# a build block invokes sources and runs provisioning steps on them.
build {
  sources = ["source.amazon-ebs.myprojectImage"]

  provisioner "file" {
    destination = "/tmp/elastic.repo"
    source      = "./elastic.repo"
  }

  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo mv /tmp/elastic.repo /etc/yum.repos.d/elastic.repo",
      "sudo yum repolist all -v",
      "sudo yum update -y",
      "sudo yum install -y filebeat",
      "sudo systemctl enable filebeat",
      "sudo yum install -y httpd",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
}
