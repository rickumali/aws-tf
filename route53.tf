data "aws_route53_zone" "existing_zone" {
  name = "test.gitmol.com"
}

resource "aws_route53_record" "example_route53_record" {
  zone_id = data.aws_route53_zone.existing_zone.id
  name    = "${var.test_subdomain_name}.test.gitmol.com"
  type    = "A"

  alias {
    name                   = aws_elb.example_elb.dns_name
    zone_id                = aws_elb.example_elb.zone_id
    evaluate_target_health = true
  }
}
