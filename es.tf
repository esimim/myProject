resource "aws_iam_service_linked_role" "es-myproject" {
  aws_service_name = "es.amazonaws.com"
}

data "aws_region" "current" {}

resource "aws_elasticsearch_domain" "es-myproject" {
  domain_name = "es-myproject"
  elasticsearch_version = "7.9"

  cluster_config {
      instance_count = 3
      instance_type = "t2.small.elasticsearch"
      zone_awareness_enabled = true

      zone_awareness_config {
        availability_zone_count = 3
      }
  }

  vpc_options {
      subnet_ids = [
        aws_subnet.myProject-private.id,
        aws_subnet.myProject-private1.id,
        aws_subnet.myProject-private2.id
      ]

      security_group_ids = [
          aws_security_group.es.id
      ]
  }

  ebs_options {
      ebs_enabled = true
      volume_size = 10
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": "es:*",
          "Principal": "*",
          "Effect": "Allow",
          "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/es-myproject/*"
      }
  ]
}
  CONFIG

  snapshot_options {
      automated_snapshot_start_hour = 23
  }

  tags = {
      Domain = "es-myproject"
  }
}

output "elk_endpoint" {
  value = aws_elasticsearch_domain.es-myproject.endpoint
}

output "elk_kibana_endpoint" {
  value = aws_elasticsearch_domain.es-myproject.kibana_endpoint
}