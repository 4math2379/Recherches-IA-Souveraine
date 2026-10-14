# Non-secret settings. Secrets come from GitHub secrets (SCW_*, TF_VAR_hf_token).
region = "fr-par"
zone   = "fr-par-2"

platform = {
  name_prefix           = "analytics"
  inference_mode        = "generative_api"
  serverless_fallback   = true
  gateway_domain        = ""
  acme_email            = ""
  allowed_api_cidrs     = ["0.0.0.0/0"]
  bastion_allowed_cidrs = []
  ssh_public_keys       = []
}

app_instance_type   = "PLAY2-MICRO"
clickhouse_replicas = 1
clickhouse_cpu_min  = 2
clickhouse_cpu_max  = 4
db_node_type        = "DB-DEV-M"
