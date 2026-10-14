variable "project_id" {
  description = "Scaleway project ID. Null uses SCW_DEFAULT_PROJECT_ID."
  type        = string
  default     = null
}

variable "region" {
  type    = string
  default = "fr-par"
}

variable "zone" {
  description = "fr-par-2 has the widest GPU catalogue."
  type        = string
  default     = "fr-par-2"
}

variable "platform" {
  description = "Platform settings (see modules/platform/variables.tf). Unset attributes keep their defaults."
  type        = any
  default     = {}
}

variable "hf_token" {
  description = "Hugging Face token, only for gated models in gpu_instance mode."
  type        = string
  default     = ""
  sensitive   = true
}

variable "app_instance_type" {
  description = "Instance for Superset + Open WebUI + MCP (16 GB recommended for production)."
  type        = string
  default     = "PLAY2-MICRO"
}

variable "clickhouse_version" {
  description = "scw datawarehouse version list"
  type        = string
  default     = "v26"
}

variable "clickhouse_replicas" {
  description = "1 for a pilot (preset essential), 2+ for high availability."
  type        = number
  default     = 1
}

variable "clickhouse_cpu_min" {
  type    = number
  default = 2
}

variable "clickhouse_cpu_max" {
  type    = number
  default = 4
}

variable "clickhouse_ca_cert" {
  description = "PEM CA of the Data Warehouse endpoint, if its certificate is not publicly trusted (scw datawarehouse deployment get-certificate)."
  type        = string
  default     = ""
}

variable "superset_image" {
  type    = string
  default = "docker.io/apache/superset:5.0.0"
}

variable "open_webui_image" {
  type    = string
  default = "ghcr.io/open-webui/open-webui:main"
}

variable "clickhouse_mcp_package" {
  description = "PyPI package spec of the ClickHouse MCP server. Pin a version in production."
  type        = string
  default     = "mcp-clickhouse"
}

variable "db_node_type" {
  type    = string
  default = "DB-DEV-M"
}
