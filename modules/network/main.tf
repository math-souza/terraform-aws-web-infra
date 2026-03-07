resource "aws_vpc" "webserver_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "web-server-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.webserver_vpc.id
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.webserver_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.webserver_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.webserver_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.webserver_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}
