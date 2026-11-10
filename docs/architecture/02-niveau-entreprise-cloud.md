# Niveau 2 — Entreprise Cloud Souverain
> Scaleway / Mistral Compute pour ETI et grands comptes

---

## Architecture

- Reseau : VPC prive Scaleway fr-par-1, VPN IPSec
- Orchestration : Kubernetes Kapsule (Cilium CNI)
- Gateway : LiteLLM (2 pods HA)
- Modeles : Mistral API La Plateforme UE ou vLLM self-hosted sur GPU Scaleway
- Stockage : Object Storage S3 UE, PostgreSQL manage
- Securite : pas d'IP publique sur les GPU, secrets dans Secret Manager

## Conformite

| Exigence | Solution |
|----------|----------|
| RGPD | DPA signe, donnees UE |
| NIS2 | MFA, logs, segmentation |
| DORA | HA multi-AZ, PRA |
| AI Act | Tracabilite, documentation |
| Cloud Act | Immune (droit UE uniquement) |
| SecNumCloud | Scaleway/Mistral eligibles |

## Deploiement

Voir [scaleway-terraform.md](../deploiement/scaleway-terraform.md)

## Cout indicatif/mois

| Poste | Cout |
|-------|------|
| GPU Scaleway (2x H100) | 3-8k EUR |
| K8s + noeuds CPU | 500-1500 EUR |
| Stockage + BDD | 200-500 EUR |
| LiteLLM + monitoring | 300-800 EUR |
| API Mistral | 500-5k EUR |
| **Total** | **~5k-15k EUR/mois** |
