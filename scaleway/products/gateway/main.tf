# Product "Passerelle": the OpenAI-compatible Mistral API on its own.

module "platform" {
  source = "../../modules/platform"

  project_id = var.project_id
  hf_token   = var.hf_token
  settings   = merge({ name_prefix = "souverain" }, var.platform)
}
