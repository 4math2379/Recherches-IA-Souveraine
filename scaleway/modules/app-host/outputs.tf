# Depends only on inputs, so the gateway can route to this host before it exists.
output "hostname" {
  description = "DNS name on the private network."
  value       = "${var.name}.${var.internal_domain}"
}

output "private_ip" {
  value = data.scaleway_ipam_ip.this.address
}
