# ---------------------------------------------------------------------------
# gpu_instance: vLLM on a GPU Instance, private interface only.
# ---------------------------------------------------------------------------

resource "scaleway_instance_server" "llm" {
  count = local.s.inference_mode == "gpu_instance" ? 1 : 0

  name              = "${local.s.name_prefix}-llm"
  type              = local.s.gpu_instance_type
  image             = local.s.gpu_image
  security_group_id = scaleway_instance_security_group.private.id
  tags              = local.s.tags

  root_volume {
    size_in_gb  = local.s.gpu_root_volume_gb
    volume_type = "sbs_volume"
  }

  private_network {
    pn_id = scaleway_vpc_private_network.main.id
  }

  user_data = {
    cloud-init = templatefile("${path.module}/templates/llm-cloud-init.yaml.tftpl", {
      image        = local.images.vllm
      model        = local.s.gpu_model
      vllm_args    = local.s.gpu_vllm_args
      vllm_api_key = random_password.vllm_api_key.result
      hf_token     = var.hf_token
    })
  }

  # The NAT route must exist before first boot, or cloud-init cannot pull the image.
  depends_on = [scaleway_vpc_gateway_network.main]
}

data "scaleway_ipam_ip" "llm" {
  count       = local.s.inference_mode == "gpu_instance" ? 1 : 0
  mac_address = scaleway_instance_server.llm[0].private_network[0].mac_address
  type        = "ipv4"
}

# ---------------------------------------------------------------------------
# managed_inference: Scaleway-operated GPUs, endpoint inside the private network.
# ---------------------------------------------------------------------------

data "scaleway_inference_model" "managed" {
  count = local.s.inference_mode == "managed_inference" ? 1 : 0
  name  = local.s.managed_inference_model
}

resource "scaleway_inference_deployment" "managed" {
  count = local.s.inference_mode == "managed_inference" ? 1 : 0

  name      = "${local.s.name_prefix}-inference"
  node_type = local.s.managed_inference_node_type
  model_id  = data.scaleway_inference_model.managed[0].id
  min_size  = local.s.managed_inference_min_size
  max_size  = max(local.s.managed_inference_min_size, 1)
  tags      = local.s.tags

  # Authentication is handled by the gateway; the endpoint is only reachable
  # from the private network.
  private_endpoint {
    private_network_id = scaleway_vpc_private_network.main.id
    disable_auth       = true
  }
}
