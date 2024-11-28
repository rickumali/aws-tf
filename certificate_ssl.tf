data "aws_acm_certificate" "devcert" {
  domain = "${local.test_subdomain_name}.test.gitmol.com"
}
