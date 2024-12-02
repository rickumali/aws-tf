data "aws_acm_certificate" "devcert" {
  for_each = toset(var.test_subdomain_names)
  domain   = "${each.value}.test.gitmol.com"
}
