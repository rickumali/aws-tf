data "aws_acm_certificate" "devcert" {
  domain = "${local.test_subdomain_name}.test.gitmol.com"
}

data "aws_acm_certificate" "httpbincert" {
  domain = "httpbin.test.gitmol.com"
}
