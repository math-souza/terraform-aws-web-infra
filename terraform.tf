terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket = "webserver-project-matheus" 
    key    = "webserver/terraform.tfstate"   
    region = "us-east-1"
    encrypt = true
  }

}

