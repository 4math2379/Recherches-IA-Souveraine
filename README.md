# 🇫🇷 Recherches IA Souveraine — Architecture & Déploiement

> **Projet** : Infrastructure IA souveraine France pour Vibe (Mistral)
> **Branche** : `infra/scaleway-mistral-test`
> **Auteur** : 4Math · CCL Consulting
> **Date** : Novembre 2026

---

## 🎯 Vision

Proposer une **architecture IA souveraine à 3 niveaux**, adaptée à tous les profils de clients français :

| Niveau | Cible | Hébergement | Sécurité |
|--------|-------|-------------|----------|
| 🥇 **Confidentiel Défense** | OIV, défense, secret industriel | On-premise air-gapped | Maximale |
| 🥈 **Entreprise Cloud** | ETI, grands comptes, secteur régulé | Scaleway / Mistral Compute | Élevée |
| 🥉 **TPE/PME SaaS** | TPE, PME, indépendants | Vibe Enterprise managé | Standard souveraine |

---

## 🏗️ Stack technique

- **LLM** : Mistral Large 3, Mistral Medium, Codestral (open-weights Apache 2.0)
- **Gateway LLM** : LiteLLM (proxy multi-modèles, gestion des clés, quotas)
- **Orchestration GPU** : Slurm + InfiniBand (on-premise), Kubernetes (cloud)
- **Infrastructure cloud** : Scaleway (GPU instances), Mistral Compute
- **Agent** : Vibe (Mistral) avec connecteurs MCP
- **Conformité** : RGPD, NIS2, DORA, AI Act européen

---

## 📁 Structure du repo

```
docs/
├── architecture/          ← Schémas et décisions d'architecture
│   ├── 00-vue-ensemble.md
│   ├── 01-niveau-confidentiel-defense.md
│   ├── 02-niveau-entreprise-cloud.md
│   ├── 03-niveau-tpe-pme-saas.md
│   └── schemas/           ← Schémas Mermaid
├── deploiement/           ← Guides de déploiement (suivent le code)
│   ├── llm-gateway-litellm.md
│   ├── slurm-infiniband-onprem.md
│   └── scaleway-terraform.md
└── conformite/            ← RGPD, NIS2, DORA, AI Act
```
