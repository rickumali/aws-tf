data "aws_route53_zone" "existing_zone" {
  name = "test.gitmol.com"
}

resource "aws_route53_record" "example_route53_record" {
  for_each = toset(var.test_subdomain_names)
  zone_id  = data.aws_route53_zone.existing_zone.id
  name     = "${each.value}.test.gitmol.com"
  type     = "A"

  alias {
    name                   = aws_lb.example_alb.dns_name
    zone_id                = aws_lb.example_alb.zone_id
    evaluate_target_health = true
  }
}
