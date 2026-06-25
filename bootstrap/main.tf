terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "us-east-1"
}

# BUCKET S3 PARA TF.STATE
resource "aws_s3_bucket" "bkt-tfstate-webserver" {
  bucket = "msalmeida-tfstate-webserver-project"

  tags = {
    Name        = "Bucket tf.state webserver"
  }
}

# BLOQUEANDO ACESSO PUBLICO AO BUCKET
resource "aws_s3_bucket_public_access_block" "tfstate_public_access_block" {
  bucket = aws_s3_bucket.bkt-tfstate-webserver.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DEFININDO A CRIPTOGRAFIA DO BUCKET
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_criptografia" {
  bucket = aws_s3_bucket.bkt-tfstate-webserver.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# HABILITANDO VERSIONAMENTO
resource "aws_s3_bucket_versioning" "tfstate-versioning" {
  bucket = aws_s3_bucket.bkt-tfstate-webserver.id

  versioning_configuration {
    status = "Enabled"
  }
}

# LIFECYCLE RULE
resource "aws_s3_bucket_lifecycle_configuration" "versionamento-bucket-config" {
  # Deve ter o versionamento do bucket habilitado previamente
  depends_on = [aws_s3_bucket_versioning.tfstate-versioning]

  bucket = aws_s3_bucket.bkt-tfstate-webserver.bucket

  rule {
    id = "prod"

    expiration {
      days = 15
    }

    status = "Enabled"
  }
}


# CRIANDO DYNAMODB LOCKTABLE
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-msalmeida"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
