output "elk_endpoint" {
  value = aws_elasticsearch_domain.myproject_es.endpoint
}

output "elk_kibana_endpoint" {
  value = aws_elasticsearch_domain.myproject_es.kibana_endpoint
}
