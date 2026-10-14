output "api_base_url" {
  value = module.platform.api_base_url
}

output "api_models" {
  value = module.platform.api_models
}

output "inference_mode" {
  value = module.platform.inference_mode
}

output "master_key_secret_id" {
  description = "scw secret version access <id> revision=latest raw=true"
  value       = module.platform.master_key_secret_id
}

output "public_ip" {
  description = "Point <domain> and *.<domain> here."
  value       = module.platform.public_ip
}

output "ssh_jump" {
  value = module.platform.ssh_jump
}
