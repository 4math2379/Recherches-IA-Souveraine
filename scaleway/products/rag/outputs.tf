output "app_url" {
  description = "Open WebUI. Create the admin account right after the first apply."
  value       = "https://${module.platform.domain}"
}

output "api_base_url" {
  value = module.platform.api_base_url
}

output "documents_bucket" {
  value = scaleway_object_bucket.documents.name
}

output "embedding_model" {
  value = local.settings.generative_embedding_model
}

output "inference_mode" {
  value = module.platform.inference_mode
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
