variable "MY_PUBLIC_KEY" {
  default = "~/.ssh/id_rsa_elastic.pub"
}

variable "MY_AWS_REGION" {
  default = "us-east-1"
}

variable "AMIS" {
  type = map(string)
  default = {    
    us-east-1 = "ami-06125574e1a3f52fd" #packer build
    #us-east-1 = "ami-0742b4e673072066f" #aws AMI
    #us-east-1 = "ami-05abe61be48f4079a" #this is my packer image with httpd
    #us-east-1 = "ami-03eaf3b9c3367e75c"
  }
}
