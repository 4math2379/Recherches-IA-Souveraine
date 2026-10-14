output "host" {
  value = scaleway_rdb_instance.this.private_network[0].ip
}

output "port" {
  value = scaleway_rdb_instance.this.private_network[0].port
}

output "user" {
  value = var.admin_user
}

output "password" {
  value     = random_password.admin.result
  sensitive = true
}

output "urls" {
  description = "postgresql:// URL per database."
  value = {
    for db in var.databases :
    db => "postgresql://${var.admin_user}:${random_password.admin.result}@${scaleway_rdb_instance.this.private_network[0].ip}:${scaleway_rdb_instance.this.private_network[0].port}/${db}"
  }
  sensitive = true
}
