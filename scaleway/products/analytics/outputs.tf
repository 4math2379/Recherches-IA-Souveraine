output "chat_url" {
  description = "Analyst chat (Open WebUI). Create the admin account right after the first apply."
  value       = "https://${module.platform.domain}"
}

output "bi_url" {
  description = "Superset (user admin)."
  value       = "https://bi.${module.platform.domain}"
}

output "landing_bucket" {
  value = scaleway_object_bucket.landing.name
}

output "clickhouse_private_host" {
  value = local.clickhouse_host
}

output "clickhouse_secret_id" {
  description = "Credentials, endpoint and landing bucket keys (JSON)."
  value       = scaleway_secret.clickhouse.id
}

output "bi_secret_id" {
  description = "Superset admin password and MCP bearer token (JSON)."
  value       = scaleway_secret.bi.id
}

output "api_base_url" {
  value = module.platform.api_base_url
}

output "public_ip" {
  description = "Point <domain> and *.<domain> here."
  value       = module.platform.public_ip
}

output "ssh_jump" {
  value = module.platform.ssh_jump
}
