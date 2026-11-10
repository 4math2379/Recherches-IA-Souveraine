# Niveau 1 — Confidentiel Defense / Secret
> Architecture on-premise air-gapped avec Slurm + InfiniBand

---

## Architecture materielle

Topologie spine-leaf InfiniBand (voir schema : [niveau-secret-infiniband.svg](schemas/niveau-secret-infiniband.svg))

| Role | Specification | Qte |
|------|--------------|-----|
| Noeuds compute | 8x NVIDIA H100/B200 80GB, 2x CPU 64c, 1TB RAM, dual IB HDR | 6-64+ |
| Controleur Slurm | slurmctld + slurmdbd + MariaDB, HA | 2 |
| Gateway LiteLLM | 2x CPU 32c, 256GB RAM, HA | 2 |
| Stockage | NVMe + BeeGFS/Lustre, 500TB+ | 3+ |
| Switchs IB | Spine + Leaf HDR/NDR | 4+ |

## Stack logiciel

- Portail Vibe interne (SSO, MFA)
- LiteLLM Gateway HA (air-gapped)
- Slurm slurmctld + slurmdbd (quotas par client)
- vLLM multi-noeuds (NCCL over InfiniBand)
- BeeGFS/Lustre (stockage local)

## Securite

- Reseau : air-gapped total, VLANs isoles
- Acces : bastion interne, MFA, carte a puce, habilitation CD
- Chiffrement : LUKS au repos, IPSec interne en transit
- Modeles : poids Mistral locaux, aucune telemetrie
- Audit : logs locaux vers SIEM interne

## Deploiement

Voir [slurm-infiniband-onprem.md](../deploiement/slurm-infiniband-onprem.md) et [llm-gateway-litellm.md](../deploiement/llm-gateway-litellm.md)

## Cout indicatif

| Poste | Cout |
|-------|------|
| Hardware (6 noeuds H100) | 400-600k EUR |
| Switchs IB + cablage | 100-150k EUR |
| Stockage 500TB | 80-120k EUR |
| Logiciels | 0 EUR (open-source) |
| **Total CAPEX** | **~600k-900k EUR** |
| **OPEX/an** | **~150-250k EUR** |
