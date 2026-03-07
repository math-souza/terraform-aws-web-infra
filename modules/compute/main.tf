# Web Servers
resource "aws_instance" "web_a" {
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1a-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-webserver.name
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/userdata.sh", {
    bucket_name = "website-project-matheus"
  })
  
  tags = {
    name = "web-server-a"
  }

  depends_on = [
    aws_nat_gateway.webserver-nat,
    aws_vpc_endpoint.webserver-s3-endpoint
  ]
}

resource "aws_instance" "web_b" {
  ami                         = "ami-0c1fe732b5494dc14"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.priv-sub-1b-webserver.id
  vpc_security_group_ids      = [aws_security_group.ec2-sg-webserver.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile-webserver.name
  user_data_replace_on_change = true

  user_data = templatefile("${path.module}/userdata.sh", {
    bucket_name = "website-project-matheus"
  })
  
  tags = {
    name = "web-server-b"
  }

  depends_on = [
    aws_nat_gateway.webserver-nat,
    aws_vpc_endpoint.webserver-s3-endpoint
  ]
}

# Security Group ALB
resource "aws_security_group" "alb-sg-webserver" {
  vpc_id = aws_vpc.web-server-vpc.id
  description = "SG para o Application Load Balancer"
  name = "alb-sg-webserver"

  ingress {
    description = "HTTP para Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS para Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permitir toda saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-webserver"
  }
}

# Security Group EC2
resource "aws_security_group" "ec2-sg-webserver" {
  name = "ec2-sg-webserver"
  description = "SG para Instancias EC2 Web Server"
  vpc_id = aws_vpc.web-server-vpc.id

  ingress {
    description = "HTTP para ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg-webserver.id]
  }

  egress {
    description = "Permitir toda saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg-webserver"
  }
}
