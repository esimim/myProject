variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

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

variable "MY_PUBLIC_KEY" {
  default = "mykey.pub"
}

data "aws_caller_identity" "current" {}
