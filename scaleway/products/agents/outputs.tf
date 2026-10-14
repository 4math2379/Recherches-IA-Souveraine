output "app_url" {
  description = "Langflow (user admin, password in Secret Manager)."
  value       = "https://${module.platform.domain}"
}

output "admin_password_secret_id" {
  value = scaleway_secret.langflow_admin.id
}

output "api_base_url" {
  value = module.platform.api_base_url
}

output "api_models" {
  value = module.platform.api_models
}

output "internal_api_base_url" {
  description = "Base URL to put in Langflow model components."
  value       = module.platform.internal_api_base_url
}

output "master_key_secret_id" {
  value = module.platform.master_key_secret_id
}

output "public_ip" {
  description = "Point <domain> and *.<domain> here."
  value       = module.platform.public_ip
}

output "ssh_jump" {
  value = module.platform.ssh_jump
}
