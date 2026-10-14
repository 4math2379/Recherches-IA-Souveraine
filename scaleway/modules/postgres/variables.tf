variable "name" {
  type = string
}

variable "private_network_id" {
  type = string
}

variable "node_type" {
  description = "DB-DEV-M (4 GB) for a pilot; DB-PRO2-XS or larger in production."
  type        = string
  default     = "DB-DEV-M"
}

variable "engine" {
  type    = string
  default = "PostgreSQL-17"
}

variable "high_availability" {
  type    = bool
  default = false
}

variable "admin_user" {
  description = "Initial (admin) user. Apps use it because they create extensions such as pgvector."
  type        = string
  default     = "app_admin"
}

variable "databases" {
  type = list(string)
}

variable "tags" {
  type    = list(string)
  default = []
}
