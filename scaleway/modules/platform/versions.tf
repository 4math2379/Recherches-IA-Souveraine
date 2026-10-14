terraform {
  required_version = ">= 1.9"

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

locals {
  s = var.settings
}
