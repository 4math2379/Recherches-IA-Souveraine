# 🔒 Niveau 1 — Confidentiel Défense / Secret
> Architecture on-premise air-gapped avec Slurm + InfiniBand

---

## 🖥️ Architecture matérielle

```
         ┌─────────────┐
         │ SPINE SWITCH │  ← InfiniBand NDR/HDR (400-800 Gb/s)
         │  (2x pour HA) │
         └──────┬──────┘
                │
    ┌───────────┼───────────┐
    ▼           ▼           ▼
┌───────┐   ┌───────┐   ┌───────┐
│ LEAF 1│   │ LEAF 2│   │ LEAF 3│
│36p HDR│   │36p HDR│   │36p HDR│
└─┬─┬─┬─┘   └─┬─┬─┬─┘   └─┬─┬─┬─┘
  │ │ │       │ │ │       │ │ │
 gpu1..gpu6  (8x H100 80GB chacun)
```

| Rôle | Spécification | Qté |
|------|--------------|-----|
| Nœuds compute | 8x NVIDIA H100/B200 80GB, 2x CPU 64c, 1TB RAM, dual IB HDR | 6-64+ |
| Contrôleur Slurm | slurmctld + slurmdbd + MariaDB, HA | 2 |
| Gateway LiteLLM | 2x CPU 32c, 256GB RAM, HA | 2 |
| Stockage | NVMe + BeeGFS/Lustre, 500TB+ | 3+ |
| Switchs IB | Spine + Leaf HDR/NDR | 4+ |

---

## ⚙️ Stack logiciel

```
┌────────────────────────────────┐
│   PORTAIL VIBE (interne)        │
├────────────────────────────────┤
│   LITELLM GATEWAY (HA)          │  ← air-gapped
├────────────────────────────────┤
│   SLURM (slurmctld + slurmdbd)  │  ← quotas par client
├────────────────────────────────┤
│   vLLM multi-nœuds (NCCL/IB)    │  ← Mistral open-weights
├────────────────────────────────┤
│   INFINIBAND FABRIC (spine-leaf)│
├────────────────────────────────┤
│   STOCKAGE (BeeGFS/Lustre)      │
└────────────────────────────────┘
   ↑ AIR-GAPPED — aucune route externe
```

---

## 🔐 Sécurité

- **Réseau** : Air-gapped total, VLANs isolés
- **Accès** : Bastion interne, MFA, carte à puce, habilitation CD
- **Chiffrement** : LUKS au repos, IPSec interne en transit
- **Modèles** : Poids Mistral locaux, aucune télémétrie
- **Audit** : Logs locaux → SIEM interne (Wazuh on-prem)
- **MàJ** : Procédure air-gapped manuelle (USB signé, SHA vérifié)

---

## 📋 Déploiement
👉 [docs/deploiement/slurm-infiniband-onprem.md](../deploiement/slurm-infiniband-onprem.md)
👉 [docs/deploiement/llm-gateway-litellm.md](../deploiement/llm-gateway-litellm.md)

## 💰 Coût indicatif
| Poste | Coût |
|-------|------|
| Hardware (6 nœuds H100) | 400-600k€ |
| Switchs IB + câblage | 100-150k€ |
| Stockage 500TB | 80-120k€ |
| Logiciels | 0€ (open-source) |
| **Total CAPEX** | **~600k-900k€** |
| **OPEX/an** | **~150-250k€** |
