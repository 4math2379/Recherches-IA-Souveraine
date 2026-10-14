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
