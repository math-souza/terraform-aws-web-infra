# Security Group ALB
resource "aws_security_group" "alb-sg-webserver" {
  vpc_id = aws_vpc.web-server-vpc.id
  description = "SG para o Application Load Balancer"
  name = var.sg_alb_name

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
  name = var.sg_ec2_name
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
