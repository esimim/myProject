variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "MY_AWS_REGION" {
  default = "us-east-1"
}

variable "AMIS" {
  type = map(string)
  default = {
    us-east-1 = "ami-0742b4e673072066f"
    #us-east-1 = "ami-03eaf3b9c3367e75c"
  }
}

variable "MY_PUBLIC_KEY" {
  default = "mykey.pub"
}

data "aws_caller_identity" "current" {}
