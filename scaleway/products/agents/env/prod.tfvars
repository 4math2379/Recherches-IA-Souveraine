# Non-secret settings. Secrets come from GitHub secrets (SCW_*, TF_VAR_hf_token).
region = "fr-par"
zone   = "fr-par-2"

platform = {
  name_prefix           = "agents"
  inference_mode        = "generative_api"
  serverless_fallback   = true
  gateway_domain        = ""
  acme_email            = ""
  allowed_api_cidrs     = [] # fail closed: 403 to everyone while empty, e.g. ["203.0.113.10/32"]
  bastion_allowed_cidrs = []
  ssh_public_keys       = []
}

app_instance_type   = "PLAY2-MICRO"
enable_scaleway_mcp = false
db_node_type        = "DB-DEV-M"
