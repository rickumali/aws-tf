variable "ingress_cidr_blocks" {
  description = "An array of CIDR blocks for ELB ingress"
  type        = list(string)
  default     = ["96.230.64.226/32", "73.4.138.165/32"]
}