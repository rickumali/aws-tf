data "aws_route53_zone" "existing_zone" {
  name = "test.gitmol.com"
}

resource "aws_route53_record" "example_route53_record" {
  zone_id = data.aws_route53_zone.existing_zone.id
  name    = "${local.test_subdomain_name}.test.gitmol.com"
  type    = "A"

  alias {
    name                   = aws_lb.example_alb.dns_name
    zone_id                = aws_lb.example_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "httpbin_route53_record" {
  zone_id = data.aws_route53_zone.existing_zone.id
  name    = "httpbin.test.gitmol.com"
  type    = "A"

  alias {
    name                   = aws_lb.example_alb.dns_name
    zone_id                = aws_lb.example_alb.zone_id
    evaluate_target_health = true
  }
}
