# Configuracao do AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Configuracao da VPC
resource "aws_vpc" "web-server-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "web-server-vpc"
  }
}

# Configuracao do Internet Gateway
resource "aws_internet_gateway" "web-server-igw" {
  vpc_id = aws_vpc.web-server-vpc.id

  tags = {
    Name = "web-server-igw"
  }
}

# Configuacao de subnets
resource "aws_subnet" "pub-sub-1a-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = us-east-1a

  tags = {
    Name = "pub-sub-1a-webserver"
  }
}

resource "aws_subnet" "pub-sub-1b-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = us-east-1b

  tags = {
    Name = "pub-sub-1b-webserver"
  }
}

resource "aws_subnet" "priv-sub-1a-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = us-east-1a

  tags = {
    Name = "priv-sub-1a-webserver"
  }
}

resource "aws_subnet" "priv-sub-1b-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = us-east-1b

  tags = {
    Name = "priv-sub-1b-webserver"
  }
}

# Configuracao das Route Table
resource "aws_route_table" "pub-rtb-webserver" {
  vpc_id = aws_vpc.web-server-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "aws_internet_gateway.web-server-igw.id"
  }
  tags = {
    Name = "pub-rtb-webserver"
  }
}

resource "aws_route_table" "priv-rtb-webserver" {
  vpc_id = aws_vpc.web-server-vpc.id

  route {
    cidr_block = "10.0.4.0/24"
    gateway_id = ""
  }
  tags = {
    Name = "priv-rtb-webserver"
  }
}






































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


