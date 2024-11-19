resource "aws_acm_certificate" "devcert" {
  domain_name       = "${var.test_subdomain_name}.test.gitmol.com"
  validation_method = "DNS"

  tags = {
    Environment = "Development"
  }
}

resource "aws_route53_record" "certificate_validation" {
  for_each = {
    for d in aws_acm_certificate.devcert.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.existing_zone.id
}


