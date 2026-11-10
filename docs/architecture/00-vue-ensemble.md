# 🏛️ Vue d'ensemble — Architecture IA Souveraine 3 Niveaux

> **Document** : Architecture globale
> **Version** : 1.0 — Novembre 2026

---

## 🎯 Principe directeur

Une **même plateforme Vibe/Mistral**, déployée à **3 niveaux de sécurité** :

```
┌─────────────────────────────────────────────────────────────┐
│                    PLATEFORME VIBE (Mistral)                  │
│         Agents · Connecteurs MCP · LLM Gateway LiteLLM        │
├─────────────────────────────────────────────────────────────┤
│  🥇 NIVEAU SECRET          │  🥈 NIVEAU ENTREPRISE           │  🥉 NIVEAU TPE/PME           │
│  Confidentiel Défense      │  Cloud Souverain                 │  SaaS Managé                 │
│  On-premise air-gapped     │  Scaleway / Mistral Compute      │  Vibe Enterprise             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🥇 Niveau 1 — Confidentiel Défense / Secret

| Aspect | Détail |
|--------|--------|
| **Clients** | OIV, ministère des Armées, industrie de défense, nucléaire |
| **Hébergement** | On-premise, air-gapped |
| **Réseau** | InfiniBand interne, aucune connexion Internet |
| **Orchestration** | Slurm + InfiniBand spine-leaf, vLLM multi-nœuds |
| **Modèles** | Mistral open-weights (Apache 2.0) locaux |
| **Gateway** | LiteLLM on-prem, aucune route externe |
| **Accès** | Réseau classifié, MFA, habilitation |

👉 Voir [01-niveau-confidentiel-defense.md](01-niveau-confidentiel-defense.md)

---

## 🥈 Niveau 2 — Entreprise Cloud Souverain

| Aspect | Détail |
|--------|--------|
| **Clients** | ETI, grands comptes, banques, santé, collectivités |
| **Hébergement** | Scaleway (GPU France), Mistral Compute |
| **Réseau** | VPC privé, VPN/IPSec |
| **Orchestration** | Kubernetes Kapsule ou VM GPU |
| **Modèles** | Mistral API La Plateforme ou self-hosted Scaleway |
| **Gateway** | LiteLLM sur Scaleway |
| **Conformité** | DPA RGPD, NIS2, DORA, AI Act |

👉 Voir [02-niveau-entreprise-cloud.md](02-niveau-entreprise-cloud.md)

---

## 🥉 Niveau 3 — TPE/PME SaaS

| Aspect | Détail |
|--------|--------|
| **Clients** | TPE, PME, indépendants |
| **Hébergement** | Vibe Enterprise managé CCL |
| **Réseau** | Internet standard, TLS 1.3 |
| **Modèles** | Mistral Large via API (hébergement UE) |
| **Gateway** | LiteLLM managé, quotas par client |
| **Conformité** | DPA RGPD signé |

👉 Voir [03-niveau-tpe-pme-saas.md](03-niveau-tpe-pme-saas.md)
