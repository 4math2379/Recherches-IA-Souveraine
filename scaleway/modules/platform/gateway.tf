# AI gateway: LiteLLM (single OpenAI-compatible API, keys, routing, fallback)
# behind Caddy (TLS). Reached from the internet only through the Public Gateway PAT rules.

locals {
  project_id         = data.scaleway_account_project.current.id
  litellm_master_key = "sk-${random_password.litellm_master_key.result}"
  gateway_private_ip = data.scaleway_ipam_ip.gateway.address
  api_domain         = local.s.gateway_domain != "" ? local.s.gateway_domain : "${replace(scaleway_vpc_public_gateway_ip.main.address, ".", "-")}.sslip.io"
  genai_base_url     = "https://api.scaleway.ai/${local.project_id}/v1"

  registry = local.s.use_scaleway_registry ? scaleway_registry_namespace.mirror[0].endpoint : ""
  images = {
    for name, ref in local.s.images : name => (
      local.registry == "" ? ref : "${local.registry}/${element(split("/", ref), length(split("/", ref)) - 1)}"
    )
  }

  # Backend behind the "mistral-chat" alias. Applications never change.
  chat_backend = {
    generative_api = {
      model    = local.s.generative_chat_model
      api_base = local.genai_base_url
      key_env  = "SCW_GENAI_KEY"
    }
    gpu_instance = {
      model    = "mistral"
      api_base = local.s.inference_mode == "gpu_instance" ? "http://${data.scaleway_ipam_ip.llm[0].address}:8000/v1" : ""
      key_env  = "VLLM_API_KEY"
    }
    managed_inference = {
      model    = local.s.inference_mode == "managed_inference" ? scaleway_inference_deployment.managed[0].model_name : ""
      api_base = local.s.inference_mode == "managed_inference" ? "${scaleway_inference_deployment.managed[0].private_endpoint[0].url}/v1" : ""
      key_env  = "NO_AUTH_KEY"
    }
  }[local.s.inference_mode]

  # Caddy sites: subdomain => upstream. The API always answers on api.<domain>.
  sites = merge(
    { "api" = "litellm:4000" },
    contains(keys(var.apps), "") ? {} : { "" = "litellm:4000" },
    var.apps,
  )
}

resource "scaleway_registry_namespace" "mirror" {
  count       = local.s.use_scaleway_registry ? 1 : 0
  name        = "${local.s.name_prefix}-mirror"
  description = "Mirror of the public images used by the sovereign AI stack"
  is_public   = true # images are public upstream; avoids storing registry credentials on Instances
}

resource "scaleway_instance_server" "gateway" {
  name              = "${local.s.name_prefix}-gateway"
  type              = local.s.gateway_instance_type
  image             = "ubuntu_noble"
  security_group_id = scaleway_instance_security_group.private.id
  tags              = local.s.tags

  root_volume {
    size_in_gb  = 20
    volume_type = "sbs_volume"
  }

  private_network {
    pn_id = scaleway_vpc_private_network.main.id
  }

  user_data = {
    cloud-init = templatefile("${path.module}/templates/gateway-cloud-init.yaml.tftpl", {
      litellm_image       = local.images.litellm
      caddy_image         = local.images.caddy
      domain              = local.api_domain
      acme_email          = local.s.acme_email
      allowed_cidrs       = join(" ", local.s.allowed_api_cidrs)
      chat                = local.chat_backend
      dedicated_backend   = local.s.inference_mode != "generative_api"
      serverless_fallback = local.s.serverless_fallback
      genai_base_url      = local.genai_base_url
      genai_chat_model    = local.s.generative_chat_model
      genai_embed_model   = local.s.generative_embedding_model
      extra_models        = var.extra_models
      sites               = local.sites
      litellm_master_key  = local.litellm_master_key
      scw_genai_key       = scaleway_iam_api_key.genai.secret_key
      vllm_api_key        = random_password.vllm_api_key.result
    })
  }

  depends_on = [scaleway_vpc_gateway_network.main]
}

data "scaleway_ipam_ip" "gateway" {
  mac_address = scaleway_instance_server.gateway.private_network[0].mac_address
  type        = "ipv4"
}
