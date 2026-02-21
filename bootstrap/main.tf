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

# HABILITANDO VERSIONAMENTO
resource "aws_s3_bucket_versioning" "tfstate-versioning" {
  bucket = aws_s3_bucket.bkt-tfstate-webserver.id

  versioning_configuration {
    status = "Enabled"
  }
}

# CRIANDO A "PASTA"
resource "aws_s3_object" "tfstate-folder" {
  bucket = aws_s3_bucket.bkt-tfstate-webserver.id
  key    = "prod/"
  content = ""
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
