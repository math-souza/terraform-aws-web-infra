######################################################### ROUTE 53 #########################################################
data "aws_route53_zone" "primary" {
  name         = "msalmeida.com.br"
  private_zone = false
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "msalmeida.com.br"
  type    = "A"

  alias {
    name                   = aws_lb.web-server-alb.dns_name
    zone_id                = aws_lb.web-server-alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www.msalmeida.com.br"
  type    = "A"

  alias {
    name                   = aws_lb.web-server-alb.dns_name
    zone_id                = aws_lb.web-server-alb.zone_id
    evaluate_target_health = true
  }
}

######################################################### ACM #########################################################
data "aws_acm_certificate" "cert" {
  domain      = "msalmeida.com.br"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
