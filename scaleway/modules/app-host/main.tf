# A private Instance running a Docker Compose application. No public IP: it is
# published by the platform gateway (Caddy) and reaches the internet through NAT.

terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.85"
    }
  }
}

locals {
  dir = "/opt/${var.name}"

  cloud_config = {
    package_update = true
    packages       = ["docker.io", "docker-compose-v2"]
    write_files = concat(
      [
        {
          path        = "${local.dir}/.env"
          permissions = "0600"
          content     = join("\n", [for k, v in var.env : "${k}=${v}"])
        },
        {
          path        = "${local.dir}/compose.yaml"
          permissions = "0644"
          content     = var.compose
        },
      ],
      [for p, f in var.files : { path = "${local.dir}/${p}", permissions = f.permissions, content = f.content }],
    )
    runcmd = concat(
      ["systemctl enable --now docker", "cd ${local.dir} && docker compose up -d --build"],
      [for c in var.post_commands : "cd ${local.dir} && ${c}"],
    )
  }
}

resource "scaleway_instance_server" "this" {
  name              = var.name
  type              = var.instance_type
  image             = var.image
  security_group_id = var.security_group_id
  tags              = var.tags

  root_volume {
    size_in_gb  = var.root_volume_gb
    volume_type = "sbs_volume"
  }

  private_network {
    pn_id = var.private_network_id
  }

  user_data = {
    cloud-init = "#cloud-config\n${yamlencode(local.cloud_config)}"
  }
}

data "scaleway_ipam_ip" "this" {
  mac_address = scaleway_instance_server.this.private_network[0].mac_address
  type        = "ipv4"
}
