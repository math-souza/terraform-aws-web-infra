backend "s3" {
  bucket = "webserver-project-matheus" 
  key    = "webserver/terraform.tfstate"   
  region = "us-east-1"
  encrypt = true
}

