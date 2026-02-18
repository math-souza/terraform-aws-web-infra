```markdown
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-orange)
![Status](https://img.shields.io/badge/Status-Working-success)
```

# 🚀 AWS Infraestrutura Web com Terraform

Projeto de infraestrutura em nuvem utilizando AWS e Terraform para provisionamento automatizado de uma aplicação web altamente disponível.

## 📌 Objetivo

Provisionar uma arquitetura segura e escalável contendo:

- Application Load Balancer (ALB)
- EC2 em subnets privadas
- S3 para armazenamento dos arquivos do site
- VPC com subnets públicas e privadas
- Internet Gateway
- NAT Gateway (para saída da subnet privada)
- VPC Endpoint para S3
- Route 53 (DNS)
- Certificado TLS via ACM
- HTTPS com redirecionamento automático

Toda a infraestrutura é criada via Infrastructure as Code (IaC) utilizando Terraform.

---

## 🏗️ Arquitetura

Fluxo da aplicação:

Usuário → DNS (Route 53) → ALB (HTTPS) → Target Group → EC2 (subnet privada) → S3

### Componentes:

- VPC customizada
- 2 Subnets públicas (para ALB)
- 2 Subnets privadas (para EC2)
- Security Groups segregados
- EC2 sem IP público
- Acesso administrativo via Systems Manager (SSM)
- Health Check configurado no Target Group
- Redirecionamento HTTP → HTTPS

---

## 🔐 Segurança

- EC2 em subnet privada
- Sem acesso SSH público
- Acesso via AWS Systems Manager
- Security Group do ALB permite apenas HTTP/HTTPS
- Comunicação EC2 ↔ S3 via VPC Endpoint
- Certificado TLS gerenciado pelo ACM

---

## 🧰 Tecnologias Utilizadas

- AWS
- Terraform
- Amazon EC2
- Application Load Balancer
- Amazon S3
- Amazon Route 53
- AWS Certificate Manager (ACM)
- AWS Systems Manager (SSM)

---

## 🚀 Como Executar

### 1️⃣ Inicializar Terraform

```bash
terraform init
```

### 2️⃣ Validar

```bash
terraform validate
terraform plan
```

### 3️⃣ Aplicar infraestrutura

```bash
terraform apply
```

### 4️⃣ Destruir ambiente

```bash
terraform destroy
```

---

## 🌐 Deploy da Aplicação
O site é armazenado em um bucket no Amazon S3 e copiado automaticamente para a instância EC2 através de script user_data durante o provisionamento.

Exemplo do user_data:
```bash
#!/bin/bash
yum update -y
yum install -y nginx aws-cli
aws s3 cp s3://SEU_BUCKET/ /usr/share/nginx/html/ --recursive
systemctl enable nginx
systemctl start nginx
```

---

## 📈 Próximas melhorias

- Auto Scaling Group
- Pipeline CI/CD
- Deploy automatizado via GitHub Actions
- Monitoramento com CloudWatch
- Logs centralizados
- Infraestrutura modularizada

---

## 👨‍💻 Autor
Matheus Almeida
Cloud Engineer | AWS Certified Solutions Architect Associate
AWS Certified Developer Associate

---
