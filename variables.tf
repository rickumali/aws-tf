variable "ingress_cidr_blocks" {
  description = "An array of CIDR blocks for SSH ingress"
  type        = list(string)
  default     = ["96.230.64.226/32", "73.4.138.165/32"]
}

variable "test_subdomain_names" {
  description = "An array of subdomain names (first one is the default)"
  type        = list(string)
  default     = ["web", "httpbin", "whoami"]
}
