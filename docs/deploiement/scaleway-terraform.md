# Deploiement Scaleway — Terraform (Niveau Entreprise)

> Infrastructure as Code pour l'architecture cloud souveraine sur Scaleway (fr-par-1).

---

## Structure

```
terraform/
├── main.tf
├── variables.tf
├── vpc.tf        ← reseau prive
├── kubernetes.tf ← Kapsule K8s
├── gpu.tf        ← instances GPU
└── secrets.tf    ← Scaleway Secret Manager
```

## main.tf

```hcl
terraform {
  required_providers {
    scaleway = { source = "scaleway/scaleway", version = "~> 2.0" }
  }
}
provider "scaleway" {
  region = "fr-par-1"
  zone   = "fr-par-1a"
}
```

## vpc.tf

```hcl
resource "scaleway_vpc_private_network" "ia" {
  name   = "vpc-ia-souveraine"
  region = "fr-par-1"
}
```

## kubernetes.tf — Kapsule

```hcl
resource "scaleway_k8s_cluster" "ia" {
  name    = "ia-souveraine"
  region  = "fr-par-1"
  version = "1.30"
  cni     = "cilium"
  node_pool {
    name        = "gateway-pool"
    node_type   = "DEV1-M"
    autoscaling = true
    min_size    = 2
    max_size    = 4
  }
}
```

## gpu.tf — Instances GPU (sans IP publique)

```hcl
resource "scaleway_instance_server" "gpu_h100" {
  count  = var.gpu_h100_count
  name   = "gpu-h100-${count.index}"
  type   = "H100-1-GPU-80GB"
  image  = "ubuntu_jammy"
  region = "fr-par-1"
  private_network { id = scaleway_vpc_private_network.ia.id }
}
```

## Commandes

```bash
terraform init
terraform plan -var="gpu_h100_count=2"
terraform apply -var="gpu_h100_count=2"
```

## Securite

| Mesure | Implementation |
|--------|----------------|
| Pas d'IP publique GPU | VPC prive uniquement |
| VPN obligatoire | VPN IPSec Scaleway |
| Secrets chiffres | Secret Manager |
| Donnees en France | Region fr-par-1 |
