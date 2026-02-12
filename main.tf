# Configuracao do AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Configuracao da VPC

# Configuracao da EC2

# AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# Instancia
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "web-instance"
  }
}

