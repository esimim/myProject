# AWS ElasticSearch Service + EC2 = Terraform + Packer
Criar um cluster Amazon Elasticsearch Service de alta disponibilidade e em seguida criar uma instância EC2 monitorada via Beats já configurada para enviar os dados para o cluster ElasticSearch. Com a imagem já provisionada e configurada o tempo de criação da instãncia fica ainda menor.

## Como Instalar

Seguir os 3 passos adiante, nesta ordem, para concluir.

Pre-requisitos: ter vpc e subnet padrão na conta AWS ou especificar os valores no arquivo variables.pkvars.hcl ao criar AMI

### 1) Criar um cluster ElasticSearch Service alta disponibilidade

```bash
cd elasticsearch/
terraform init
terraform validate
AWS_PROFILE=myterraformagent terraform plan -out out.terraform
AWS_PROFILE=myterraformagent terraform apply out.terraform
```

### 2) Criar uma imagem com o software de monitoramento já provisionado inclusive com o arquivo de configuração já definido para o cluster ElasticSearch criado anteriormente

Se não houver vpn e vpc padrão informar os valores através do arquivo de variáveis:

variables.pkrvars.hcl

```bash
myvpc_id     = "vpc-xxxx"
mysubnet_id  = "subnet-xxxx"
mysource_ami = "ami-xxxx"
```

```bash
cd ../packer/
packer validate -var-file="variables.pkrvars.hcl" myprojectImageBuild.pkr.hcl
AWS_PROFILE=myterraformagent packer build -var-file="variables.pkrvars.hcl" myprojectImageBuild.pkr.hcl
```

### 3) Fazer o provisionamento do EC2 na VPC numa subnet com acesso público

```bash
cd ../ec2/
terraform init
terraform validate
AWS_PROFILE=myterraformagent terraform plan -out out.terraform
AWS_PROFILE=myterraformagent terraform apply out.terraform
```
