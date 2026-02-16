# Configuracao do AWS Provider
provider "aws" {
  region = var.region
}

######################################################### NETWORK #########################################################

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
  map_public_ip_on_launch = true

  tags = {
    Name = "pub-sub-1a-webserver"
  }
}

resource "aws_subnet" "pub-sub-1b-webserver" {
  vpc_id     = aws_vpc.web-server-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = us-east-1b
  map_public_ip_on_launch = true

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

# Configuracao da Route Table Publica
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

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.pub-sub-1a-webserver.id
  route_table_id = aws_route_table.pub-rtb-webserver.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.pub-sub-1b-webserver.id
  route_table_id = aws_route_table.pub-rtb-webserver.id
}

######################################################### SECURITY GROUP #########################################################

# Security Group ALB
resource "aws_security_group" "alb-sg-webserver" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group EC2
resource "aws_security_group" "ec2-sg-webserver" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg-webserver.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

######################################################### IAM #########################################################

# IAM Role para S3
resource "aws_iam_role" "ec2-webserver-role" {
  name = "ec2-s3-role-webserver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3-read-webserver" {
  role       = aws_iam_role.ec2-webserver-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# IAM Instance Profile para a EC2
resource "aws_iam_instance_profile" "ec2-webserver-profile" {
  name = "ec2-webserver-profile"
  role = aws_iam_role.ec2-webserver-role.name
}

######################################################### COMPUTE RESOURCES #########################################################

# Web Servers
resource "aws_instance" "web_a" {
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1a-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-webserver-profile.name
  user_data                   = file("userdata.sh")
}

resource "aws_instance" "web_b" {
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1b-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-webserver-profile.name
  user_data                   = file("userdata.sh")
}

# ALB
resource "aws_lb" "web-server-alb" {
  name               = "web-server-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg-webserver.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]
}

# Target Group
resource "aws_lb_target_group" "webserver-tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web-server-vpc.id
}

resource "aws_lb_target_group_attachment" "web-server-a" {
  target_group_arn = aws_lb_target_group.webserver-tg.arn
  target_id        = aws_instance.web_a.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web-server-b" {
  target_group_arn = aws_lb_target_group.webserver-tg.arn
  target_id        = aws_instance.web_b.id
  port             = 80
}

# Listener
resource "aws_lb_listener" "webserver-listener" {
  load_balancer_arn = aws_lb.web-server-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webserver-tg.arn
  }
}


