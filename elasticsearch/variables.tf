variable "elasticaddressfield" {
  default = "MYPROJECTELASTICSEARCHADDRESS"
}

variable "kibanaaddressfield" {
  default = "MYPROJECTKIBANAADDRESS"
}

variable "MY_AWS_REGION" {
  default = "us-east-1"
}

data "aws_caller_identity" "current" {}

