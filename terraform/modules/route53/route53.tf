resource "aws_route53_record" "odiam" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "300"
  records = [var.alb.id]
}

resource "aws_route53_record" "www" {
  zone_id = var.hosted_zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = "5"

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "www"
  records        = ["www.odiam.wordpress.support-coe.com"]
}