output "public_ip" {
  value       = aws_instance.example_instance.public_ip
  description = "The Public IP of the EC2"
}

output "vpc_id" {
  value       = data.aws_vpc.default.id
  description = "The Default VPC's ID"
}

output "domain_names" {
  value       = values(data.aws_acm_certificate.devcert)[*].domain
  description = "The newly created domain name"
}
