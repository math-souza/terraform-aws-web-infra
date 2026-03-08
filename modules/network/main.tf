# Configuracao da VPC
resource "aws_vpc" "web-server-vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.app_name}vpc"
  }
}

# Configuracao do Internet Gateway
resource "aws_internet_gateway" "web-server-igw" {
  vpc_id = aws_vpc.web-server-vpc.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

# Configuacao de subnets
resource "aws_subnet" "pub-sub-1a-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.az_a
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-1a-${var.app_name}"
  }
}

resource "aws_subnet" "pub-sub-1b-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.az_b
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-1b-${var.app_name}"
  }
}

resource "aws_subnet" "priv-sub-1a-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.az_a

  tags = {
    Name = "priv-sub-1a-${var.app_name}"
  }
}

resource "aws_subnet" "priv-sub-1b-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.az_b

  tags = {
    Name = "priv-sub-1b-${var.app_name}"
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
    Name = "pub-rtb-${var.app_name}"
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
    Name = "${var.app_name}-nat-eip"
  }

}

resource "aws_nat_gateway" "webserver-nat" {
  allocation_id = aws_eip.webserver-nat.id
  subnet_id     = aws_subnet.pub-sub-1a-webserver.id

  tags = {
    Name = "NAT-${var.app_name}"
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
    Name = "priv-rtb-${var.app_name}"
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
