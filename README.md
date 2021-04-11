# AWS ElasticSearch Service + EC2 = Terraform + Packer
Criar um cluster Amazon Elasticsearch Service com uma instância EC2 enviando Beats para o cluster ElasticSearch.

1) Gerar uma imagem (AWS AMI) com o software de monitoramento já provisionado utilizando o Packer
packer validate myprojectImageBuild.pkr.hcl
packer build myprojectImageBuild.pkr.hcl

2) Fazer o provisionamento do ElasticSearch e da EC2 
terraform validate
terraform plan -out out.terraform
terraform apply out.terraform
