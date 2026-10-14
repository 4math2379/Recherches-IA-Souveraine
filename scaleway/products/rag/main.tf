# Product "RAG": chat with your documents. Open WebUI (UI, document ingestion,
# retrieval) on a private Instance, pgvector in Managed PostgreSQL, files in
# Object Storage, Mistral and embeddings through the platform gateway.

locals {
  settings = merge({
    name_prefix = "rag"
    # 3 584 dimensions: fits pgvector's halfvec HNSW index (4 000 max).
    # qwen3-embedding-8b (4 096) does not.
    generative_embedding_model = "bge-multilingual-gemma2"
  }, var.platform)
  prefix = local.settings.name_prefix
}

module "platform" {
  source = "../../modules/platform"

  project_id = var.project_id
  hf_token   = var.hf_token
  settings   = local.settings
  apps       = { "" = "${module.webui.hostname}:8080" }
}

module "db" {
  source = "../../modules/postgres"

  name               = "${local.prefix}-db"
  private_network_id = module.platform.private_network_id
  node_type          = var.db_node_type
  high_availability  = var.db_high_availability
  databases          = ["openwebui"]
  tags               = local.settings.tags
}

# ---------------------------------------------------------------------------
# Document storage
# ---------------------------------------------------------------------------

resource "random_id" "bucket" {
  byte_length = 4
}

resource "scaleway_object_bucket" "documents" {
  name = "${local.prefix}-documents-${random_id.bucket.hex}"
  tags = { product = "rag" }

  versioning {
    enabled = true
  }
}

resource "scaleway_iam_application" "storage" {
  name        = "${local.prefix}-storage"
  description = "Open WebUI access to the document bucket"
}

resource "scaleway_iam_policy" "storage" {
  name           = "${local.prefix}-storage"
  application_id = scaleway_iam_application.storage.id

  rule {
    project_ids = [module.platform.project_id]
    permission_set_names = [
      "ObjectStorageBucketsRead",
      "ObjectStorageObjectsRead",
      "ObjectStorageObjectsWrite",
      "ObjectStorageObjectsDelete",
    ]
  }
}

resource "scaleway_iam_api_key" "storage" {
  application_id     = scaleway_iam_application.storage.id
  default_project_id = module.platform.project_id
  description        = "Open WebUI -> Object Storage"
}

# ---------------------------------------------------------------------------
# Open WebUI
# ---------------------------------------------------------------------------

resource "random_password" "webui_secret" {
  length  = 48
  special = false
}

module "webui" {
  source = "../../modules/app-host"

  name               = "${local.prefix}-webui"
  instance_type      = var.app_instance_type
  private_network_id = module.platform.private_network_id
  internal_domain    = module.platform.internal_domain
  security_group_id  = module.platform.security_group_id
  tags               = local.settings.tags

  compose = templatefile("${path.module}/templates/compose.yaml.tftpl", {
    image = var.open_webui_image
  })

  env = {
    WEBUI_URL         = "https://${module.platform.domain}"
    WEBUI_SECRET_KEY  = random_password.webui_secret.result
    ENABLE_SIGNUP     = "true" # the first account becomes admin; later ones wait for approval
    DEFAULT_USER_ROLE = "pending"
    # Terraform is the source of truth: settings are not frozen in the database.
    ENABLE_PERSISTENT_CONFIG = "false"

    # Models through the platform gateway only
    ENABLE_OLLAMA_API         = "false"
    ENABLE_DIRECT_CONNECTIONS = "false"
    OPENAI_API_BASE_URL       = module.platform.internal_api_base_url
    OPENAI_API_KEY            = module.platform.master_key
    DEFAULT_MODELS            = "mistral-chat"

    # Retrieval
    RAG_EMBEDDING_ENGINE                  = "openai"
    RAG_EMBEDDING_MODEL                   = "embeddings"
    RAG_OPENAI_API_BASE_URL               = module.platform.internal_api_base_url
    RAG_OPENAI_API_KEY                    = module.platform.master_key
    VECTOR_DB                             = "pgvector"
    DATABASE_URL                          = module.db.urls["openwebui"]
    PGVECTOR_DB_URL                       = module.db.urls["openwebui"]
    PGVECTOR_INITIALIZE_MAX_VECTOR_LENGTH = "3584"
    PGVECTOR_USE_HALFVEC                  = "true"

    # Uploaded files
    STORAGE_PROVIDER     = "s3"
    S3_ENDPOINT_URL      = "https://s3.${var.region}.scw.cloud"
    S3_REGION_NAME       = var.region
    S3_BUCKET_NAME       = scaleway_object_bucket.documents.name
    S3_ACCESS_KEY_ID     = scaleway_iam_api_key.storage.access_key
    S3_SECRET_ACCESS_KEY = scaleway_iam_api_key.storage.secret_key

    # Nothing leaves Scaleway at run time
    ENABLE_WEB_SEARCH    = "false"
    ANONYMIZED_TELEMETRY = "false"
    DO_NOT_TRACK         = "true"
    SCARF_NO_ANALYTICS   = "true"
  }
}
