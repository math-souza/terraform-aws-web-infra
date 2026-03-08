output "alb_dns_name" {
  value = aws_lb.web-server-alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.web-server-alb.zone_id
}
