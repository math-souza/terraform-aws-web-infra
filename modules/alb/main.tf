# ALB
resource "aws_lb" "web-server-alb" {
  name               = "web-server-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg-webserver.id]
  subnets            = [aws_subnet.pub-sub-1a-webserver.id, aws_subnet.pub-sub-1b-webserver.id]

  enable_deletion_protection = false

  tags = {
    Name = "web-server-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "webserver-tg" {
  name     = "webserver-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web-server-vpc.id

  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  deregistration_delay = 30

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
resource "aws_lb_listener" "webserver-http-listener" {
  load_balancer_arn = aws_lb.web-server-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "webserver-https-listener" {
  load_balancer_arn = aws_lb.web-server-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.webserver-tg.arn
  }
}
