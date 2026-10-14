# Managed PostgreSQL reachable only from the private network (no public endpoint),
# encrypted at rest, with daily backups. pgvector is available as an extension.

terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.85"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}

# Scaleway requires upper, lower, digit and special characters; keep them URL-safe.
resource "random_password" "admin" {
  length           = 32
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "-_"
}

resource "scaleway_rdb_instance" "this" {
  name                      = var.name
  node_type                 = var.node_type
  engine                    = var.engine
  is_ha_cluster             = var.high_availability
  user_name                 = var.admin_user
  password                  = random_password.admin.result
  encryption_at_rest        = true
  backup_schedule_frequency = 24
  backup_schedule_retention = 7
  tags                      = var.tags

  # No load_balancer block: the instance gets no public endpoint.
  private_network {
    pn_id       = var.private_network_id
    enable_ipam = true
  }
}

resource "scaleway_rdb_database" "this" {
  for_each    = toset(var.databases)
  instance_id = scaleway_rdb_instance.this.id
  name        = each.value
}

resource "scaleway_rdb_privilege" "this" {
  for_each      = scaleway_rdb_database.this
  instance_id   = scaleway_rdb_instance.this.id
  user_name     = var.admin_user
  database_name = each.value.name
  permission    = "all"
}
