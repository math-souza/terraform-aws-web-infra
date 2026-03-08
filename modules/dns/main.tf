######################################################### ROUTE 53 #########################################################
data "aws_route53_zone" "primary" {
  name         = var.root_domain
  private_zone = false
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.root_domain
  type    = "A"

  alias {
    name                   = aws_lb.web-server-alb.dns_name
    zone_id                = aws_lb.web-server-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.alias_domain
  type    = "A"

  alias {
    name                   = aws_lb.web-server-alb.dns_name
    zone_id                = aws_lb.web-server-alb.zone_id
    evaluate_target_health = true
  }
}

######################################################### ACM #########################################################
data "aws_acm_certificate" "cert" {
  domain      = var.root_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
