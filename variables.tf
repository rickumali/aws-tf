variable "ingress_cidr_blocks" {
  description = "An array of CIDR blocks for ELB ingress"
  type        = list(string)
  default     = ["96.230.64.226/32", "73.4.138.165/32"]
}

variable "zone_id" {
  description = "Zone ID for domain name"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}
