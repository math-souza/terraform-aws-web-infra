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
  
  default_tags{
    tags = {
      Environment = "prod"
      Project = "terraform-infra-webserver"
    }
  }
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
    id = "rule-prod"

    filter{}

    noncurrent_version_expiration {
      noncurrent_days = 3
    }

    status = "Enabled"
  }
}

# RECUPERANDO O ID DO USER
data "aws_caller_identity" "current" { }


# BUCKET POLICY
resource "aws_s3_bucket_policy" "allow-access-from-user-terraform" {
  bucket = aws_s3_bucket.bkt-tfstate-webserver.id
  policy = data.aws_iam_policy_document.allow-access-from-user-terraform.json
}

# POLICY PARA ACESSO AO BUCKET
data "aws_iam_policy_document" "allow-access-from-user-terraform" {
  statement {
      sid = "bucket-level"
      effect = "Allow"

      principals { 
        type = "AWS"
        identifiers = [data.aws_caller_identity.current.arn] 
      }

      actions = ["s3:ListBucket", "s3:GetBucketVersioning"]

      resources = ["$aws_s3_bucket.bkt-tfstate-webserver.arn"]
    }
  
  statement {
      sid =  "object-level"
      effect = "Allow"

      principals { 
        type = "AWS"
        identifiers = [data.aws_caller_identity.current.arn]
      }
       
      actions = ["s3:GetObject", "s3:PutObject", "s3:HeadObject"]

      resources = ["$aws_s3_bucket.bkt-tfstate-webserver.arn/*"]
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

  tags = {
    Name = "DynamoBD-LockTable-webserver-infra"
  }
}
