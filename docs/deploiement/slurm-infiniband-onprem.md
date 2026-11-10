# ⚙️ Déploiement On-Premise — Slurm + InfiniBand (Niveau Secret)
> Basé sur le lab CCL_Lab_Slurm_InfiniBand — Slurm 26.05 + OpenSM + fabric IB

---

## 🖥️ Topologie production

```
         ┌─────────────┐
         │ SPINE SWITCH │  NDR 400Gb/s, 2x pour HA
         └──────┬──────┘
    ┌───────────┼───────────┐
    ▼           ▼           ▼
┌───────┐   ┌───────┐   ┌───────┐
│ LEAF 1│   │ LEAF 2│   │ LEAF 3│
│36p HDR│   │36p HDR│   │36p HDR│
└─┬─┬─┬─┘   └─┬─┬─┬─┘   └─┬─┬─┬─┘
  │ │ │       │ │ │       │ │ │
 gpu nodes (8x H100 80GB chacun)
```

---

## 🔧 Installation Slurm 26.05
```bash
# Sur chaque nœud
sudo apt install -y build-essential libmunge-dev libmariadb-dev munge hwloc
wget https://download.schedmd.com/slurm/slurm-26.05.4.tar.bz2
tar xjf slurm-26.05.4.tar.bz2 && cd slurm-26.05.4
./configure --prefix=/opt/slurm-26.05 --sysconfdir=/etc/slurm26 --enable-multiple-slurmd
make -j$(nproc) && sudo make install
```

## 🌐 Configuration InfiniBand
```bash
sudo apt install -y infiniband-diags opensm
ibnetdiscover > /etc/slurm26/topology_raw.net
# Convertir en topology.conf (script ib2slurm.py du lab CCL)
ibnetdiscover | python3 ib2slurm.py --hosts gpu1,gpu2,gpu3,gpu4,gpu5,gpu6 > /etc/slurm26/topology.conf
ibstat  # vérifier état des ports HCA
```

## 📝 slurm.conf (exemple 6 nœuds)
```bash
ClusterName=ccl-secret
SlurmctldHost=ctrl1
SlurmctldHost=ctrl2  # backup
AuthType=auth/munge
SelectType=select/cons_tres
TopologyPlugin=topology/tree
GresTypes=gpu
AccountingStorageType=accounting_storage/slurmdbd
AccountingStorageEnforce=associations,limits,qos
AccountingStorageTRES=gres/gpu
NodeName=gpu[1-6] CPUs=128 RealMemory=1000000 Gres=gpu:8 State=UNKNOWN
PartitionName=gpu Nodes=gpu[1-6] Default=YES MaxTime=INFINITE State=UP
Prolog=/etc/slurm26/prolog-ib.sh
PrologFlags=Alloc
```

## 👥 Comptes clients et quotas
```bash
sudo sacctmgr add account client-defense -d "Ministère des Armées"
sudo sacctmgr add user jean.dupont account=client-defense
sudo sacctmgr modify account client-defense set GrpTRES=gres/gpu=16
```

## 🧠 vLLM multi-nœuds (NCCL over InfiniBand)
```bash
export NCCL_IB_DISABLE=0
export NCCL_IB_HCA=mlx5_0,mlx5_1
export NCCL_SOCKET_IFNAME=eth0

vllm serve mistralai/Mistral-Large-3 \
  --tensor-parallel-size 8 \
  --pipeline-parallel-size 8 \
  --distributed-executor-backend ray \
  --host 0.0.0.0 --port 8000
```

## 🔀 LiteLLM on-prem (air-gapped)
Voir [llm-gateway-litellm.md](llm-gateway-litellm.md) — tout passe par vLLM local, aucune clé API externe.
