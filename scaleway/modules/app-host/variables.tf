variable "name" {
  description = "Instance name; also its DNS name on the private network."
  type        = string
}

variable "instance_type" {
  type    = string
  default = "PLAY2-MICRO"
}

variable "image" {
  type    = string
  default = "ubuntu_noble"
}

variable "root_volume_gb" {
  type    = number
  default = 40
}

variable "private_network_id" {
  description = "Use the platform output, which waits for the NAT route."
  type        = string
}

variable "internal_domain" {
  description = "Platform output internal_domain."
  type        = string
}

variable "security_group_id" {
  type = string
}

variable "tags" {
  type    = list(string)
  default = []
}

variable "compose" {
  description = "Content of compose.yaml."
  type        = string
}

variable "env" {
  description = "Written to .env (mode 0600), read by compose."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "files" {
  description = "Extra files, relative to the app directory."
  type = map(object({
    content     = string
    permissions = optional(string, "0644")
  }))
  default = {}
}

variable "post_commands" {
  description = "Commands run in the app directory after 'docker compose up'."
  type        = list(string)
  default     = []
}
