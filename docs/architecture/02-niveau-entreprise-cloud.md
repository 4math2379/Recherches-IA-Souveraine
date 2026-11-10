# 🏢 Niveau 2 — Entreprise Cloud Souverain
> Scaleway / Mistral Compute pour ETI et grands comptes

---

## ☁️ Architecture

```
INTERNET (TLS 1.3)
    │ VPN/IPSec
    ▼
┌──────────────────────────────────────┐
│   SCALEWAY VPC (Paris, France) 🇫🇷    │
│  ┌─────────┐ ┌─────────┐ ┌────────┐ │
│  │ Kapsule │ │ LiteLLM │ │ Mistral│ │
│  │  K8s    │ │ Gateway │ │Compute │ │
│  └────┬────┘ └────┬────┘ └───┬────┘ │
│       │           │          │      │
│  ┌────┴───────────┴────┐     │      │
│  │  GPU Scaleway       │←────┘      │
│  │  L4/L40S/H100       │            │
│  └─────────────────────┘            │
└──────────────────────────────────────┘
```

---

## 🧩 Composants

| Composant | Technologie | Rôle |
|-----------|-------------|------|
| Compute GPU | Scaleway L40S/H100 | Inférence self-hosted |
| Orchestration | Kapsule K8s | Vibe, LiteLLM, monitoring |
| Gateway | LiteLLM (2 pods HA) | Routing, quotas, cache |
| Modèles | Mistral API ou vLLM | Inférence |
| Stockage | Object Storage S3 UE | Documents, embeddings |
| BDD | PostgreSQL managé | Données Vibe |
| Réseau | VPC privé + VPN IPSec | Isolation |
| Identité | SSO (SAML/OIDC) | Authentification |

---

## 🔐 Conformité

| Exigence | Solution |
|----------|----------|
| RGPD | DPA signé, données UE |
| NIS2 | MFA, logs, segmentation |
| DORA | HA multi-AZ, PRA |
| AI Act | Traçabilité, documentation |
| Cloud Act | ✅ Immune (droit UE uniquement) |
| SecNumCloud | ✅ Scaleway/Mistral éligibles |

---

## 📋 Déploiement
👉 [docs/deploiement/scaleway-terraform.md](../deploiement/scaleway-terraform.md)

## 💰 Coût indicatif/mois
| Poste | Coût |
|-------|------|
| GPU Scaleway (2x H100) | 3-8k€ |
| K8s + nœuds CPU | 500-1500€ |
| Stockage + BDD | 200-500€ |
| LiteLLM + monitoring | 300-800€ |
| API Mistral (si usage API) | 500-5k€ |
| **Total** | **~5k-15k€/mois** |
