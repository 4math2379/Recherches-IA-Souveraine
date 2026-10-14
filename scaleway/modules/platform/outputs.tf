# Taken from the gateway network rather than the private network itself, so that
# anything attached with this ID waits for the NAT route (needed at first boot).
output "private_network_id" {
  description = "Private network ID for product resources."
  value       = scaleway_vpc_gateway_network.main.private_network_id
}

output "security_group_id" {
  description = "Security group for product Instances (inbound dropped)."
  value       = scaleway_instance_security_group.private.id
}

output "project_id" {
  value = local.project_id
}

output "domain" {
  description = "Base domain; apps are published on <subdomain>.<domain>."
  value       = local.api_domain
}

output "api_base_url" {
  description = "Public OpenAI-compatible base URL."
  value       = "https://api.${local.api_domain}/v1"
}

output "internal_domain" {
  description = "Private network DNS zone: Instances answer at <name>.<internal_domain>."
  value       = "${scaleway_vpc_private_network.main.name}.internal"
}

# Built from names (VPC internal DNS), so apps do not depend on the gateway Instance
# and the gateway does not depend on the apps: no cycle, no needless recreation.
output "internal_api_base_url" {
  description = "OpenAI-compatible base URL for apps inside the private network."
  value       = "http://${local.s.name_prefix}-gateway.${scaleway_vpc_private_network.main.name}.internal:4000/v1"
}

output "master_key" {
  description = "Gateway master key, for product apps."
  value       = local.litellm_master_key
  sensitive   = true
}

output "master_key_secret_id" {
  description = "Secret Manager ID holding the gateway master key."
  value       = scaleway_secret.litellm_master_key.id
}

output "api_models" {
  description = "Model aliases exposed by the gateway."
  value = concat(
    ["mistral-chat", "embeddings"],
    local.s.inference_mode != "generative_api" ? ["mistral-chat-serverless"] : [],
    keys(var.extra_models),
  )
}

output "inference_mode" {
  value = local.s.inference_mode
}

output "public_ip" {
  description = "Public Gateway IP. Point <domain> and *.<domain> here."
  value       = scaleway_vpc_public_gateway_ip.main.address
}

output "ssh_jump" {
  description = "ssh -J value to reach any private Instance through the bastion."
  value       = length(local.s.bastion_allowed_cidrs) > 0 ? "bastion@${scaleway_vpc_public_gateway_ip.main.address}:61000" : null
}

output "gateway_private_ip" {
  value = local.gateway_private_ip
}

output "llm_private_ip" {
  value = local.s.inference_mode == "gpu_instance" ? data.scaleway_ipam_ip.llm[0].address : null
}

output "registry_endpoint" {
  value = local.s.use_scaleway_registry ? scaleway_registry_namespace.mirror[0].endpoint : null
}
