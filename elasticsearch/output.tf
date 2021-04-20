output "elk_endpoint" {
  value = aws_elasticsearch_domain.myprojectelk.endpoint
}

output "elk_kibana_endpoint" {
  value = aws_elasticsearch_domain.myprojectelk.kibana_endpoint
}
