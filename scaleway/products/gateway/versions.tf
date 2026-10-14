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

  # State in Scaleway Object Storage (fr-par); bucket and key passed at init.
  backend "s3" {
    region                      = "fr-par"
    endpoints                   = { s3 = "https://s3.fr-par.scw.cloud" }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
  }
}

# Credentials come from SCW_ACCESS_KEY / SCW_SECRET_KEY / SCW_DEFAULT_ORGANIZATION_ID.
provider "scaleway" {
  region     = var.region
  zone       = var.zone
  project_id = var.project_id
}
