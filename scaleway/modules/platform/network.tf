# One VPC, one private network, one Public Gateway.
# No Instance gets a public IP: ingress goes through PAT rules on the gateway,
# egress through its NAT, and SSH through its bastion.

resource "scaleway_vpc" "main" {
  name = "${local.s.name_prefix}-vpc"
  tags = local.s.tags
}

resource "scaleway_vpc_private_network" "main" {
  name   = "${local.s.name_prefix}-pn"
  vpc_id = scaleway_vpc.main.id
  tags   = local.s.tags

  ipv4_subnet {
    subnet = local.s.private_network_cidr
  }
}

resource "scaleway_vpc_public_gateway_ip" "main" {
  tags = local.s.tags
}

resource "scaleway_vpc_public_gateway" "main" {
  name              = "${local.s.name_prefix}-pgw"
  type              = "VPC-GW-S"
  ip_id             = scaleway_vpc_public_gateway_ip.main.id
  bastion_enabled   = length(local.s.bastion_allowed_cidrs) > 0
  bastion_port      = 61000
  allowed_ip_ranges = length(local.s.bastion_allowed_cidrs) > 0 ? local.s.bastion_allowed_cidrs : null
  refresh_ssh_keys  = sha256(join(",", local.s.ssh_public_keys))
  tags              = local.s.tags

  depends_on = [scaleway_iam_ssh_key.this]
}

resource "scaleway_vpc_gateway_network" "main" {
  gateway_id         = scaleway_vpc_public_gateway.main.id
  private_network_id = scaleway_vpc_private_network.main.id
  enable_masquerade  = true

  ipam_config {
    push_default_route = true
  }
}

# Public HTTPS entry point -> Caddy on the gateway Instance.
resource "scaleway_vpc_public_gateway_pat_rule" "https" {
  gateway_id   = scaleway_vpc_public_gateway.main.id
  private_ip   = local.gateway_private_ip
  private_port = 443
  public_port  = 443
  protocol     = "tcp"
}

# Needed by the ACME HTTP-01 challenge; Caddy redirects everything else to HTTPS.
resource "scaleway_vpc_public_gateway_pat_rule" "http" {
  gateway_id   = scaleway_vpc_public_gateway.main.id
  private_ip   = local.gateway_private_ip
  private_port = 80
  public_port  = 80
  protocol     = "tcp"
}

# Instances only have a private interface, so no inbound traffic from the internet
# reaches them directly. The security group still drops everything by default.
resource "scaleway_instance_security_group" "private" {
  name                    = "${local.s.name_prefix}-private"
  inbound_default_policy  = "drop"
  outbound_default_policy = "accept"
  stateful                = true
  tags                    = local.s.tags
}
