variable "elasticaddressfield" {
  default = "MYPROJECTELASTICSEARCHADDRESS"
}

variable "kibanaaddressfield" {
  default = "MYPROJECTKIBANAADDRESS"
}

variable "MY_AWS_REGION" {
  default = "us-west-2"
}

data "aws_caller_identity" "current" {}
