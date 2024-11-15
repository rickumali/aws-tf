resource "aws_route53_record" "example_route53_record" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_elb.example_elb.dns_name
    zone_id                = aws_elb.example_elb.zone_id
    evaluate_target_health = true
  }
}
