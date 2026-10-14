# Non-secret settings. Secrets come from GitHub secrets (SCW_*, TF_VAR_hf_token).
region = "fr-par"
zone   = "fr-par-2"

platform = {
  name_prefix = "souverain"

  # GPU Instances are in short supply in every zone (checked 2026-10-07): start serverless.
  inference_mode      = "generative_api" # or gpu_instance, managed_inference
  serverless_fallback = true

  gateway_domain        = "" # e.g. "ia.example.fr" (A records for it and *.it -> output public_ip)
  acme_email            = ""
  allowed_api_cidrs     = [] # fail closed: 403 to everyone while empty, e.g. ["203.0.113.10/32"]
  bastion_allowed_cidrs = [] # e.g. ["203.0.113.10/32"]
  ssh_public_keys       = []
}
