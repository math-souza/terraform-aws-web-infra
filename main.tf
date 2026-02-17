# Configuracao do AWS Provider
provider "aws" {
  region = var.region
}

######################################################### NETWORK RESOURCES #########################################################

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

# Config nat-gateway
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

######################################################### SECURITY GROUP #########################################################

# Security Group ALB
resource "aws_security_group" "alb-sg-webserver" {
  vpc_id = aws_vpc.web-server-vpc.id

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
  vpc_id = aws_vpc.web-server-vpc.id

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
# IAM Role para EC2
resource "aws_iam_role" "ec2-s3-role-webserver" {
  name = "ec2-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Permitir acesso ao bucket
resource "aws_iam_policy" "s3-read-policy" {
  name = "ec2-s3-read-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::website-project-matheus/*"
      }
    ]
  })
}

# Anexar policy a Role
resource "aws_iam_role_policy_attachment" "ec2-attach-policy" {
  role       = aws_iam_role.ec2-s3-role-webserver.name
  policy_arn = aws_iam_policy.s3-read-policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2-profile-webserver" {
  name = "ec2-s3-profile"
  role = aws_iam_role.ec2-s3-role-webserver.name
}

######################################################### COMPUTE RESOURCES #########################################################

# Web Servers
resource "aws_instance" "web_a" {
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1a-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-webserver.name
  user_data                   = file("userdata.sh")
  
  tags = {
    name = "web-server-a"
  }
}

resource "aws_instance" "web_b" {
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1b-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-webserver.name
  user_data                   = file("userdata.sh")
  
  tags = {
    name = "web-server-b"
  }
}

# ALB
resource "aws_lb" "web-server-alb" {
  name               = "web-server-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg-webserver.id]
  subnets            = [aws_subnet.pub-sub-1a-webserver.id, aws_subnet.pub-sub-1b-webserver.id]
}

# Target Group
resource "aws_lb_target_group" "webserver-tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web-server-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "web-target-group"
  }
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

######################################################### S3 #########################################################

# Criar VPC Endpoint
resource "aws_vpc_endpoint" "webserver-s3-endpoint" {
  vpc_id            = aws_vpc.web-server-vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.pub-rtb-webserver.id,
    aws_route_table.priv-rtb-webserver.id
  ]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}








