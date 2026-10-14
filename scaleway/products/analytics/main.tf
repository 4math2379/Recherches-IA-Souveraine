# Product "Analyse": ask questions of your data in French, build dashboards.
#  - Data Warehouse for ClickHouse (managed, private endpoint only)
#  - Object Storage landing bucket for CSV / Parquet files
#  - Apache Superset for dashboards (bi.<domain>)
#  - Open WebUI as the analyst chat (<domain>), querying ClickHouse through the
#    official ClickHouse MCP server, read-only
#  - Superset and Open WebUI metadata in Managed PostgreSQL

locals {
  settings = merge({
    name_prefix                = "analytics"
    generative_embedding_model = "bge-multilingual-gemma2"
  }, var.platform)
  prefix = local.settings.name_prefix

  # HTTPS interface of the private endpoint (used by Superset and the MCP server).
  clickhouse_host = scaleway_datawarehouse_deployment.this.private_network[0].dns_record
  clickhouse_port = coalesce(one([
    for s in scaleway_datawarehouse_deployment.this.private_network[0].services : s.port if s.protocol == "https"
  ]), 8443)

  # The endpoint certificate is signed by a Scaleway CA, fetched after the first apply.
  has_ca     = var.clickhouse_ca_cert != ""
  ca_in_ctnr = "/certs/clickhouse-ca.pem"
}

module "platform" {
  source = "../../modules/platform"

  project_id = var.project_id
  hf_token   = var.hf_token
  settings   = local.settings
  apps = {
    ""   = "${module.bi.hostname}:8080" # analyst chat
    "bi" = "${module.bi.hostname}:8088" # Superset
  }
  extra_models = {
    "mistral-medium" = "mistral-medium-3.5-128b"
  }
}

module "db" {
  source = "../../modules/postgres"

  name               = "${local.prefix}-db"
  private_network_id = module.platform.private_network_id
  node_type          = var.db_node_type
  databases          = ["superset", "openwebui"]
  tags               = local.settings.tags
}

# ---------------------------------------------------------------------------
# Data Warehouse for ClickHouse
# ---------------------------------------------------------------------------

resource "random_password" "clickhouse_admin" {
  length           = 32
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "-_"
}

resource "random_password" "clickhouse_analyst" {
  length           = 32
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "-_"
}

resource "scaleway_datawarehouse_deployment" "this" {
  name          = "${local.prefix}-warehouse"
  version       = var.clickhouse_version
  replica_count = var.clickhouse_replicas
  cpu_min       = var.clickhouse_cpu_min
  cpu_max       = var.clickhouse_cpu_max
  ram_per_cpu   = 4
  password      = random_password.clickhouse_admin.result
  tags          = local.settings.tags

  # No public_network block: reachable only from the private network.
  private_network {
    pn_id = module.platform.private_network_id
  }
}

resource "scaleway_datawarehouse_database" "analytics" {
  deployment_id = scaleway_datawarehouse_deployment.this.id
  name          = "analytics"
}

# Used by Superset and the MCP server. grant.sh on the BI host gives it SELECT on
# the analytics database once the endpoint CA is known (second apply, see README).
resource "scaleway_datawarehouse_user" "analyst" {
  deployment_id = scaleway_datawarehouse_deployment.this.id
  name          = "analyst"
  password      = random_password.clickhouse_analyst.result
  is_admin      = false
}

resource "scaleway_secret" "clickhouse" {
  name        = "${local.prefix}-clickhouse"
  description = "ClickHouse credentials (admin and analyst) and endpoint"
  tags        = local.settings.tags
}

resource "scaleway_secret_version" "clickhouse" {
  secret_id = scaleway_secret.clickhouse.id
  data = jsonencode({
    host               = local.clickhouse_host
    https_port         = local.clickhouse_port
    admin_user         = "scwadmin"
    admin_password     = random_password.clickhouse_admin.result
    analyst_user       = "analyst"
    analyst_password   = random_password.clickhouse_analyst.result
    landing_access_key = scaleway_iam_api_key.landing.access_key
    landing_secret_key = scaleway_iam_api_key.landing.secret_key
  })
}

# ---------------------------------------------------------------------------
# Landing bucket: drop files, load them with ClickHouse's s3() table function
# ---------------------------------------------------------------------------

resource "random_id" "bucket" {
  byte_length = 4
}

resource "scaleway_object_bucket" "landing" {
  name = "${local.prefix}-landing-${random_id.bucket.hex}"
  tags = { product = "analytics" }

  versioning {
    enabled = true
  }
}

resource "scaleway_iam_application" "landing" {
  name        = "${local.prefix}-landing"
  description = "Read access to the landing bucket for ClickHouse s3()"
}

resource "scaleway_iam_policy" "landing" {
  name           = "${local.prefix}-landing"
  application_id = scaleway_iam_application.landing.id

  rule {
    project_ids          = [module.platform.project_id]
    permission_set_names = ["ObjectStorageBucketsRead", "ObjectStorageObjectsRead"]
  }
}

resource "scaleway_iam_api_key" "landing" {
  application_id     = scaleway_iam_application.landing.id
  default_project_id = module.platform.project_id
  description        = "ClickHouse s3() -> landing bucket"
}

# ---------------------------------------------------------------------------
# BI host: Superset + Open WebUI + ClickHouse MCP server
# ---------------------------------------------------------------------------

resource "random_password" "superset_secret" {
  length  = 48
  special = false
}

resource "random_password" "superset_admin" {
  length  = 24
  special = false
}

resource "random_password" "webui_secret" {
  length  = 48
  special = false
}

resource "random_password" "mcp_token" {
  length  = 40
  special = false
}

resource "scaleway_secret" "bi" {
  name        = "${local.prefix}-bi"
  description = "Superset admin password and ClickHouse MCP bearer token"
  tags        = local.settings.tags
}

resource "scaleway_secret_version" "bi" {
  secret_id = scaleway_secret.bi.id
  data = jsonencode({
    superset_admin_user     = "admin"
    superset_admin_password = random_password.superset_admin.result
    clickhouse_mcp_url      = "http://clickhouse-mcp:8000/mcp"
    clickhouse_mcp_token    = random_password.mcp_token.result
  })
}

module "bi" {
  source = "../../modules/app-host"

  name               = "${local.prefix}-bi"
  instance_type      = var.app_instance_type
  private_network_id = module.platform.private_network_id
  internal_domain    = module.platform.internal_domain
  security_group_id  = module.platform.security_group_id
  root_volume_gb     = 60
  tags               = local.settings.tags

  compose = templatefile("${path.module}/templates/compose.yaml.tftpl", {
    superset_image = var.superset_image
    webui_image    = var.open_webui_image
    mcp_package    = var.clickhouse_mcp_package
  })

  files = {
    "superset_config.py" = { content = file("${path.module}/templates/superset_config.py") }
    "clickhouse-ca.pem"  = { content = var.clickhouse_ca_cert }
    "superset.env" = {
      permissions = "0600"
      content = join("\n", [
        "SUPERSET_SECRET_KEY=${random_password.superset_secret.result}",
        "SUPERSET_DATABASE_URI=${module.db.urls["superset"]}",
        "SUPERSET_ADMIN_PASSWORD=${random_password.superset_admin.result}",
        "CLICKHOUSE_URI=clickhousedb://analyst:${random_password.clickhouse_analyst.result}@${local.clickhouse_host}:${local.clickhouse_port}/analytics?secure=true${local.has_ca ? "&ca_cert=${local.ca_in_ctnr}" : ""}",
      ])
    }
    "grant.sh" = {
      permissions = "0700"
      content     = <<-EOT
        #!/bin/sh
        # Read-only access for the analyst user (Superset, MCP server).
        [ -s clickhouse-ca.pem ] || { echo "No ClickHouse CA yet: set clickhouse_ca_cert and apply again."; exit 0; }
        curl -sS --fail --retry 20 --retry-delay 15 --retry-all-errors --cacert clickhouse-ca.pem \
          -u "scwadmin:${random_password.clickhouse_admin.result}" \
          "https://${local.clickhouse_host}:${local.clickhouse_port}/" \
          --data-binary "GRANT SELECT ON analytics.* TO analyst"
      EOT
    }
    "clickhouse-mcp.env" = {
      permissions = "0600"
      content = join("\n", concat([
        "CLICKHOUSE_HOST=${local.clickhouse_host}",
        "CLICKHOUSE_PORT=${local.clickhouse_port}",
        "CLICKHOUSE_USER=analyst",
        "CLICKHOUSE_PASSWORD=${random_password.clickhouse_analyst.result}",
        "CLICKHOUSE_SECURE=true",
        "CLICKHOUSE_ALLOW_WRITE_ACCESS=false",
        "CLICKHOUSE_MCP_SERVER_TRANSPORT=http",
        "CLICKHOUSE_MCP_BIND_HOST=0.0.0.0",
        "CLICKHOUSE_MCP_BIND_PORT=8000",
        "CLICKHOUSE_MCP_AUTH_TOKEN=${random_password.mcp_token.result}",
        "CLICKHOUSE_MCP_ALLOWED_HOSTS=clickhouse-mcp:8000",
        ], local.has_ca ? ["CLICKHOUSE_CA_CERT=${local.ca_in_ctnr}"] : [],
      ))
    }
  }

  # Open WebUI (analyst chat)
  env = {
    WEBUI_URL                             = "https://${module.platform.domain}"
    WEBUI_SECRET_KEY                      = random_password.webui_secret.result
    ENABLE_SIGNUP                         = "true"
    DEFAULT_USER_ROLE                     = "pending"
    ENABLE_PERSISTENT_CONFIG              = "false"
    ENABLE_OLLAMA_API                     = "false"
    ENABLE_DIRECT_CONNECTIONS             = "false"
    OPENAI_API_BASE_URL                   = module.platform.internal_api_base_url
    OPENAI_API_KEY                        = module.platform.master_key
    DEFAULT_MODELS                        = "mistral-chat"
    RAG_EMBEDDING_ENGINE                  = "openai"
    RAG_EMBEDDING_MODEL                   = "embeddings"
    RAG_OPENAI_API_BASE_URL               = module.platform.internal_api_base_url
    RAG_OPENAI_API_KEY                    = module.platform.master_key
    DATABASE_URL                          = module.db.urls["openwebui"]
    VECTOR_DB                             = "pgvector"
    PGVECTOR_DB_URL                       = module.db.urls["openwebui"]
    PGVECTOR_INITIALIZE_MAX_VECTOR_LENGTH = "3584"
    PGVECTOR_USE_HALFVEC                  = "true"
    ENABLE_WEB_SEARCH                     = "false"
    ANONYMIZED_TELEMETRY                  = "false"
    DO_NOT_TRACK                          = "true"
    SCARF_NO_ANALYTICS                    = "true"
  }

  # First boot: Superset metadata, admin account, ClickHouse connection.
  post_commands = [
    "./grant.sh",
    "sleep 60",
    "docker compose exec -T superset superset db upgrade",
    "docker compose exec -T superset sh -c 'superset fab create-admin --username admin --firstname Admin --lastname BI --email admin@example.invalid --password \"$SUPERSET_ADMIN_PASSWORD\"'",
    "docker compose exec -T superset superset init",
    "docker compose exec -T superset sh -c 'superset set-database-uri --database_name ClickHouse --uri \"$CLICKHOUSE_URI\"'",
  ]
}
