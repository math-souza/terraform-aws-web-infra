# 🚀 AWS Web Infrastructure with Terraform

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
