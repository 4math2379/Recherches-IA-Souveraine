# Product "Agents": build agents and workflows visually, call them as an API.
# Langflow on a private Instance, its state in Managed PostgreSQL, models
# through the platform gateway (Mistral Small for tool calling, Devstral for
# code, Mistral Medium for harder reasoning). Optional tool: the Scaleway MCP
# server in read-only mode, so agents can inspect your infrastructure.

locals {
  settings = merge({ name_prefix = "agents" }, var.platform)
  prefix   = local.settings.name_prefix
}

module "platform" {
  source = "../../modules/platform"

  project_id = var.project_id
  hf_token   = var.hf_token
  settings   = local.settings
  apps       = { "" = "${module.langflow.hostname}:7860" }
  extra_models = {
    "devstral"       = "devstral-2-123b-instruct-2512"
    "mistral-medium" = "mistral-medium-3.5-128b"
  }
}

module "db" {
  source = "../../modules/postgres"

  name               = "${local.prefix}-db"
  private_network_id = module.platform.private_network_id
  node_type          = var.db_node_type
  high_availability  = var.db_high_availability
  databases          = ["langflow"]
  tags               = local.settings.tags
}

resource "random_password" "langflow_secret" {
  length  = 48
  special = false
}

resource "random_password" "langflow_admin" {
  length  = 24
  special = false
}

resource "scaleway_secret" "langflow_admin" {
  name        = "${local.prefix}-langflow-admin"
  description = "Langflow superuser password (user: admin)"
  tags        = local.settings.tags
}

resource "scaleway_secret_version" "langflow_admin" {
  secret_id = scaleway_secret.langflow_admin.id
  data      = random_password.langflow_admin.result
}

# ---------------------------------------------------------------------------
# Optional read-only Scaleway MCP server (a tool agents can call)
# ---------------------------------------------------------------------------

resource "scaleway_iam_application" "mcp" {
  count       = var.enable_scaleway_mcp ? 1 : 0
  name        = "${local.prefix}-scaleway-mcp"
  description = "Read-only Scaleway access for agents"
}

resource "scaleway_iam_policy" "mcp" {
  count          = var.enable_scaleway_mcp ? 1 : 0
  name           = "${local.prefix}-scaleway-mcp"
  application_id = scaleway_iam_application.mcp[0].id

  rule {
    project_ids          = [module.platform.project_id]
    permission_set_names = ["AllProductsReadOnly"]
  }
}

resource "scaleway_iam_api_key" "mcp" {
  count              = var.enable_scaleway_mcp ? 1 : 0
  application_id     = scaleway_iam_application.mcp[0].id
  default_project_id = module.platform.project_id
  description        = "Scaleway MCP server (read-only) for agents"
}

# ---------------------------------------------------------------------------
# Langflow
# ---------------------------------------------------------------------------

module "langflow" {
  source = "../../modules/app-host"

  name               = "${local.prefix}-langflow"
  instance_type      = var.app_instance_type
  private_network_id = module.platform.private_network_id
  internal_domain    = module.platform.internal_domain
  security_group_id  = module.platform.security_group_id
  tags               = local.settings.tags

  compose = templatefile("${path.module}/templates/compose.yaml.tftpl", {
    langflow_image      = var.langflow_image
    scaleway_mcp_image  = var.scaleway_mcp_image
    enable_scaleway_mcp = var.enable_scaleway_mcp
  })

  env = {
    LANGFLOW_HOST                        = "0.0.0.0"
    LANGFLOW_PORT                        = "7860"
    LANGFLOW_DATABASE_URL                = module.db.urls["langflow"]
    LANGFLOW_SECRET_KEY                  = random_password.langflow_secret.result
    LANGFLOW_AUTO_LOGIN                  = "false"
    LANGFLOW_SUPERUSER                   = "admin"
    LANGFLOW_SUPERUSER_PASSWORD          = random_password.langflow_admin.result
    LANGFLOW_STORE_ENVIRONMENT_VARIABLES = "true"
    DO_NOT_TRACK                         = "true"

    # Picked up as Langflow global variables; use them in the OpenAI model
    # component (API key + "OpenAI API Base").
    OPENAI_API_KEY  = module.platform.master_key
    OPENAI_API_BASE = module.platform.internal_api_base_url
  }

  # Separate file so Langflow never sees the Scaleway API key.
  files = var.enable_scaleway_mcp ? {
    "scaleway-mcp.env" = {
      permissions = "0600"
      content = join("\n", [
        "SCW_ACCESS_KEY=${scaleway_iam_api_key.mcp[0].access_key}",
        "SCW_SECRET_KEY=${scaleway_iam_api_key.mcp[0].secret_key}",
        "SCW_DEFAULT_PROJECT_ID=${module.platform.project_id}",
        "SCW_DEFAULT_REGION=${var.region}",
        "SCW_DEFAULT_ZONE=${var.zone}",
      ])
    }
  } : {}
}
