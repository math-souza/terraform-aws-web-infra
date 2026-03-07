######################################################### NETWORK RESOURCES #########################################################

# Configuracao da VPC
resource "aws_vpc" "web-server-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

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
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-1a-webserver"
  }
}

resource "aws_subnet" "pub-sub-1b-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-1b-webserver"
  }
}

resource "aws_subnet" "priv-sub-1a-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "priv-sub-1a-webserver"
  }
}

resource "aws_subnet" "priv-sub-1b-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "priv-sub-1b-webserver"
  }
}

# Config da Route Table Publica
resource "aws_route_table" "pub-rtb-webserver" {
  vpc_id = aws_vpc.web-server-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web-server-igw.id
  }
  tags = {
    Name = "pub-rtb-webserver"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.pub-sub-1a-webserver.id
  route_table_id = aws_route_table.pub-rtb-webserver.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.pub-sub-1b-webserver.id
  route_table_id = aws_route_table.pub-rtb-webserver.id
}

# Config NAT-gateway
resource "aws_eip" "webserver-nat" {
  domain = "vpc"
  tags = {
    Name = "webserver-nat-eip"
  }

}

resource "aws_nat_gateway" "webserver-nat" {
  allocation_id = aws_eip.webserver-nat.id
  subnet_id     = aws_subnet.pub-sub-1a-webserver.id

  tags = {
    Name = "NAT-webserver"
  }

  depends_on = [aws_internet_gateway.web-server-igw]
}

# Config Route Table Privada
resource "aws_route_table" "priv-rtb-webserver" {
  vpc_id = aws_vpc.web-server-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.webserver-nat.id
  }
  tags = {
    Name = "priv-rtb-webserver"
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.priv-sub-1a-webserver.id
  route_table_id = aws_route_table.priv-rtb-webserver.id
}

resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.priv-sub-1b-webserver.id
  route_table_id = aws_route_table.priv-rtb-webserver.id
}

# Criar VPC Endpoint S3
resource "aws_vpc_endpoint" "webserver-s3-endpoint" {
  vpc_id            = aws_vpc.web-server-vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.priv-rtb-webserver.id
  ]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}
