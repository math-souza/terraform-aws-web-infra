output "alb_sg" {
  value = aws_security_group.alb-sg-webserver.id
}

output "ec2_sg" {
  value = aws_security_group.ec2-sg-webserver.id
}
