# Vue d'ensemble — Architecture IA Souveraine 3 Niveaux

> **Document** : Architecture globale
> **Version** : 1.0 — Novembre 2026

---

## Principe directeur

Une meme plateforme Vibe/Mistral, deployee a 3 niveaux de securite :

| Niveau | Cible | Hebergement | Securite |
|--------|-------|-------------|----------|
| Niveau 1 — Confidentiel Defense | OIV, defense, secret industriel | On-premise air-gapped | Maximale |
| Niveau 2 — Entreprise Cloud | ETI, grands comptes, secteur regule | Scaleway / Mistral Compute | Elevee |
| Niveau 3 — TPE/PME SaaS | TPE, PME, independants | Vibe Enterprise manage | Standard souveraine |

---

## Niveau 1 — Confidentiel Defense / Secret

| Aspect | Detail |
|--------|--------|
| Clients | OIV, ministere des Armees, industrie de defense, nucleaire |
| Hebergement | On-premise, air-gapped |
| Reseau | InfiniBand interne, aucune connexion Internet |
| Orchestration | Slurm + InfiniBand spine-leaf, vLLM multi-noeuds |
| Modeles | Mistral open-weights (Apache 2.0) locaux |
| Gateway | LiteLLM on-prem, aucune route externe |
| Acces | Reseau classifie, MFA, habilitation |

Voir [01-niveau-confidentiel-defense.md](01-niveau-confidentiel-defense.md)

---

## Niveau 2 — Entreprise Cloud Souverain

| Aspect | Detail |
|--------|--------|
| Clients | ETI, grands comptes, banques, sante, collectivites |
| Hebergement | Scaleway (GPU France), Mistral Compute |
| Reseau | VPC prive, VPN/IPSec |
| Orchestration | Kubernetes Kapsule ou VM GPU |
| Modeles | Mistral API La Plateforme ou self-hosted Scaleway |
| Gateway | LiteLLM sur Scaleway |
| Conformite | DPA RGPD, NIS2, DORA, AI Act |

Voir [02-niveau-entreprise-cloud.md](02-niveau-entreprise-cloud.md)

---

## Niveau 3 — TPE/PME SaaS

| Aspect | Detail |
|--------|--------|
| Clients | TPE, PME, independants |
| Hebergement | Vibe Enterprise manage CCL |
| Reseau | Internet standard, TLS 1.3 |
| Modeles | Mistral Large via API (hebergement UE) |
| Gateway | LiteLLM manage, quotas par client |
| Conformite | DPA RGPD signe |

Voir [03-niveau-tpe-pme-saas.md](03-niveau-tpe-pme-saas.md)
