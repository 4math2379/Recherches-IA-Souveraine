# Every product passes one "platform" object; unset attributes take these defaults.
variable "settings" {
  description = "Platform settings (network, gateway, inference backend). See README for each attribute."
  type = object({
    name_prefix = string
    tags        = optional(list(string), ["sovereign-ai", "terraform"])

    # Where "mistral-chat" runs: generative_api | gpu_instance | managed_inference
    inference_mode             = optional(string, "generative_api")
    serverless_fallback        = optional(bool, true)
    generative_chat_model      = optional(string, "mistral-small-3.2-24b-instruct-2506")
    generative_embedding_model = optional(string, "qwen3-embedding-8b")

    gpu_instance_type  = optional(string, "L40S-1-48G")
    gpu_image          = optional(string, "ubuntu_noble_gpu_os_12")
    gpu_root_volume_gb = optional(number, 150)
    gpu_model          = optional(string, "mistralai/Mistral-Small-3.2-24B-Instruct-2506")
    gpu_vllm_args      = optional(string, "--tokenizer-mode mistral --config-format mistral --load-format mistral --quantization fp8 --max-model-len 32768")

    managed_inference_model     = optional(string, "mistral/mistral-small-3.2-24b-instruct-2506:fp8")
    managed_inference_node_type = optional(string, "L40S")
    managed_inference_min_size  = optional(number, 1)

    gateway_instance_type = optional(string, "PLAY2-NANO")
    gateway_domain        = optional(string, "")
    acme_email            = optional(string, "")
    allowed_api_cidrs     = optional(list(string), ["0.0.0.0/0"])
    bastion_allowed_cidrs = optional(list(string), [])
    ssh_public_keys       = optional(list(string), [])
    private_network_cidr  = optional(string, "172.16.32.0/22")

    use_scaleway_registry = optional(bool, false)
    images = optional(object({
      litellm = optional(string, "ghcr.io/berriai/litellm:main-stable")
      caddy   = optional(string, "docker.io/library/caddy:2")
      vllm    = optional(string, "docker.io/vllm/vllm-openai:latest")
    }), {})
  })

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.settings.name_prefix))
    error_message = "name_prefix must be 2-21 lowercase letters, digits or hyphens (it is used in DNS names)."
  }

  validation {
    condition     = contains(["generative_api", "gpu_instance", "managed_inference"], var.settings.inference_mode)
    error_message = "inference_mode must be generative_api, gpu_instance or managed_inference."
  }
}

variable "project_id" {
  description = "Scaleway project ID. Null uses the provider default."
  type        = string
  default     = null
}

variable "hf_token" {
  description = "Hugging Face token, only needed for gated models (gpu_instance mode)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "apps" {
  description = <<-EOT
    Product web apps published by Caddy, as subdomain => "host:port" on the
    private network (use <instance-name>.<internal_domain>).
    The key "" publishes on the base domain. The API is always on api.<domain>,
    and also on the base domain when no app claims it.
  EOT
  type        = map(string)
  default     = {}
}

variable "extra_models" {
  description = "Additional Generative APIs models exposed by the gateway, as alias => model name."
  type        = map(string)
  default     = {}
}
