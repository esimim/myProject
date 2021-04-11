# AWS ElasticSearch Service + EC2 = Terraform + Packer
Criar um cluster Amazon Elasticsearch Service com uma instância EC2 enviando Beats para o cluster ElasticSearch.

## Como Instalar

Pre-requisitos: terraform.tfvars e variables.pkrvars.hcl com variáveis AWS

terraform.tfvars

```AWS_ACCESS_KEY = "xxxx"
AWS_SECRET_KEY = "xxxx"
MY_PUBLIC_KEY = "~/.ssh/id_rsa.pub"
mysshpassword = "xxxx"
```

variables.pkrvars.hcl

```myvpc_id     = "vpc-xxxx"
mysubnet_id  = "subnet-xxxx"
mysource_ami = "ami-xxxx"
```

### 1) Gerar uma imagem (AWS AMI) com o software de monitoramento já provisionado utilizando o Packer

```packer validate -var="myvpc_id=vpc-xxxx" -var="mysubnet_id=vpc-xxxx" -var="mysource_ami=ami-xxxx" myprojectImageBuild.pkr.hcl
```

```
packer build -var="myvpc_id=vpc-xxxx" -var="mysubnet_id=vpc-xxxx" -var="mysource_ami=ami-xxxx" myprojectImageBuild.pkr.hcl
```

### 2) Fazer o provisionamento do ElasticSearch e da EC2 

```terraform validate
```

```terraform plan -out out.terraform
```

```terraform apply out.terraform
```
