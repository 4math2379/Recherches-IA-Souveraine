data "scaleway_account_project" "current" {
  project_id = var.project_id
}

resource "scaleway_iam_ssh_key" "this" {
  for_each   = toset(local.s.ssh_public_keys)
  name       = "${local.s.name_prefix}-${substr(sha256(each.value), 0, 8)}"
  public_key = each.value
  project_id = data.scaleway_account_project.current.id
}

# Dedicated IAM application whose only right is calling Generative APIs in this project.
resource "scaleway_iam_application" "genai" {
  name        = "${local.s.name_prefix}-genai"
  description = "Used by the AI gateway to call Scaleway Generative APIs"
  tags        = local.s.tags
}

resource "scaleway_iam_policy" "genai" {
  name           = "${local.s.name_prefix}-genai"
  description    = "Generative APIs model access, scoped to the sovereign AI project"
  application_id = scaleway_iam_application.genai.id
  tags           = local.s.tags

  rule {
    project_ids          = [data.scaleway_account_project.current.id]
    permission_set_names = ["GenerativeApisModelAccess"]
  }
}

resource "scaleway_iam_api_key" "genai" {
  application_id = scaleway_iam_application.genai.id
  description    = "AI gateway -> Generative APIs"
}

# ---------------------------------------------------------------------------
# Gateway secrets, also stored in Secret Manager for operators.
# ---------------------------------------------------------------------------

resource "random_password" "litellm_master_key" {
  length  = 40
  special = false
}

resource "random_password" "vllm_api_key" {
  length  = 40
  special = false
}

resource "scaleway_secret" "litellm_master_key" {
  name        = "${local.s.name_prefix}-litellm-master-key"
  description = "Master key of the AI gateway (OpenAI-compatible API)"
  tags        = local.s.tags
}

resource "scaleway_secret_version" "litellm_master_key" {
  secret_id = scaleway_secret.litellm_master_key.id
  data      = local.litellm_master_key
}
