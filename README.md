# Recherches : IA souveraine

Notes techniques, architectures et templates Terraform pour héberger de l'IA générative en restant maître de ses données. Les sujets couverts :

- **Cloud européen :** Mistral sur Scaleway, en région Paris.
- **Usine d'IA sur site :** GPU NVIDIA reliés par InfiniBand.
- **Ordonnancement de clusters GPU :** Slurm.

Recherches menées en septembre et octobre 2026.

> Les rapports sont des pages HTML autonomes. Ouvrez-les dans un navigateur, ou publiez le dépôt avec GitHub Pages (*Settings > Pages > Deploy from a branch*, dossier racine) : `index.html` sert alors de sommaire.

## Rapports

### Scaleway : Mistral souverain dans le cloud européen

| Rapport | Contenu |
|---|---|
| [Mistral souverain sur Scaleway](rapports/scaleway/mistral-souverain-sur-scaleway.html) | Architecture cible : passerelle d'API unique, Generative APIs, Managed Inference ou GPU dédiés, RAG pgvector. Plan de déploiement et coûts |
| [IA souveraine Scaleway](rapports/scaleway/ia-souveraine-scaleway.html) | État des GPU et des modèles Mistral disponibles, six idées de projets, trois modes d'inférence, déploiement depuis GitHub |
| [Catalogue IA souveraine](rapports/scaleway/catalogue-ia-souveraine.html) | Trois produits packagés (RAG, agents, analyse) sur un socle commun, avec schémas et mise en route |

### NVIDIA et InfiniBand : usine d'IA sur site

| Rapport | Contenu |
|---|---|
| [Usine d'IA souveraine NVIDIA](rapports/nvidia-infiniband/usine-ia-souveraine-nvidia.html) | Quantum-X800, SHARP, ConnectX-8, CUDA-Q et NVQLink. Architecture sur site et niveaux de déploiement |
| [Intégration InfiniBand souveraine](rapports/nvidia-infiniband/integration-infiniband-souveraine.html) | Fiche technique Quantum-X800, architecture de référence, recette, certifications NVIDIA |
| [Upper Layer Protocols InfiniBand](rapports/nvidia-infiniband/upper-layer-protocols-infiniband.html) | IPoIB, SRP, iSER, NFS RDMA, MPI, NCCL… Fiche de révision NCP-AIN avec auto-évaluation |
| [Le Subnet Manager InfiniBand](rapports/nvidia-infiniband/subnet-manager-infiniband.html) | Fonctionnement, configuration et exploitation du SM sur les plateformes NVIDIA |
| [Le matériel du Subnet Manager](rapports/nvidia-infiniband/materiel-subnet-manager.html) | Commutateurs managés, appliances UFM, cartes ConnectX, DPU BlueField : références et prix |
| [Lab InfiniBand local](rapports/nvidia-infiniband/lab-infiniband-local.html) | Parcours en quatre niveaux, du simulateur ibsim (testé) à la fabric commutée |

### Slurm : ordonnancement de clusters GPU

| Rapport | Contenu |
|---|---|
| [Slurm pour clusters GPU souverains](rapports/slurm/slurm-clusters-gpu-souverains.html) | Architecture, lien avec InfiniBand (topologie, santé, P_Key), POC exécuté sur fabric simulée, écosystème NVIDIA |

## Code : IA souveraine sur Scaleway

Le dossier [`scaleway/`](scaleway/README.md) contient quatre produits Terraform déployables depuis GitHub Actions. Ils partagent le même socle : réseau privé, passerelle d'API compatible OpenAI et modèles Mistral.

![Architecture du socle commun : réseau privé, Public Gateway, passerelle d'API Mistral et inférence](scaleway/docs/architecture-gateway.svg)

| Produit | Pour quoi faire |
|---|---|
| [`gateway`](scaleway/products/gateway/README.md) | API Mistral compatible OpenAI |
| [`rag`](scaleway/products/rag/README.md) | Discuter avec ses documents (Open WebUI, pgvector) |
| [`agents`](scaleway/products/agents/README.md) | Agents et workflows (Langflow, MCP) |
| [`analytics`](scaleway/products/analytics/README.md) | Interroger ses données en français (ClickHouse, Superset) |

- **Validation :** la configuration passe `terraform validate` et `terraform fmt` hors ligne, avec le provider `scaleway/scaleway` 2.85.0. Aucun produit n'a encore été déployé.
- **Workflows :** ils sont dans `.github/workflows/`. Ils attendent les secrets décrits dans `scaleway/README.md`.
- **Serveur MCP :** `.mcp.json` configure le serveur MCP Scaleway en lecture seule pour Claude Code. Les identifiants viennent des variables d'environnement `SCW_*` et ne sont jamais stockés dans le dépôt.
- **Sécurité :** le déploiement est en échec fermé par défaut (la passerelle répond `403` tant que `allowed_api_cidrs` n'est pas renseigné). Les réglages de durcissement sont détaillés dans [`scaleway/README.md`](scaleway/README.md#sécurité-par-défaut).

## Organisation

```
rapports/            pages HTML autonomes, par thème
scaleway/            templates Terraform, schémas, scripts
outils/diagrammes/   génération des schémas aux icônes officielles Scaleway
.github/workflows/   plan et apply Terraform, copie des images vers Scaleway
```

## Avertissements

- **Chiffres datés :** prix, stocks et versions ont été relevés à une date donnée. Vérifiez-les avant tout engagement.
- **Sources :** certaines pages officielles n'étaient pas lisibles depuis l'environnement de rédaction. Chaque rapport indique ses sources et ce qui reste à vérifier.
- **Mentions tierces :** voir [`NOTICE.md`](NOTICE.md).
