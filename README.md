<p align="center">
  <img src="docs/assets/banner.svg" alt="Recherches : IA souveraine. Trois couches : cloud européen (Mistral sur Scaleway), usine d'IA sur site (NVIDIA InfiniBand), clusters GPU (Slurm)" width="100%">
</p>

<p align="center">
  <img alt="Langue : français" src="https://img.shields.io/badge/langue-fran%C3%A7ais-0055A4">
  <a href="https://www.terraform.io"><img alt="Terraform" src="https://img.shields.io/badge/Terraform-scaleway%2Fscaleway%202.85-7B42BC?logo=terraform&logoColor=white"></a>
  <a href="https://www.scaleway.com"><img alt="Scaleway" src="https://img.shields.io/badge/Scaleway-fr--par-4F0599?logo=scaleway&logoColor=white"></a>
  <a href="https://mistral.ai"><img alt="Mistral AI" src="https://img.shields.io/badge/Mistral%20AI-modèles-FA520F?logo=mistralai&logoColor=white"></a>
  <a href="https://www.nvidia.com/fr-fr/networking/products/infiniband/"><img alt="NVIDIA InfiniBand" src="https://img.shields.io/badge/NVIDIA-InfiniBand-76B900?logo=nvidia&logoColor=white"></a>
  <a href="https://slurm.schedmd.com"><img alt="Slurm" src="https://img.shields.io/badge/Slurm-clusters%20GPU-44C4A4"></a>
  <a href=".github/workflows"><img alt="GitHub Actions" src="https://img.shields.io/badge/GitHub%20Actions-plan%20%2B%20apply-2088FF?logo=githubactions&logoColor=white"></a>
</p>

<p align="center">
  <b>Héberger de l'IA générative en restant maître de ses données</b><br>
  notes techniques, architectures et templates Terraform : Mistral sur Scaleway, usine d'IA NVIDIA InfiniBand sur site, clusters GPU Slurm.
</p>

<p align="center">
  <a href="#rapports">Rapports</a> ·
  <a href="#code-scaleway">Code Scaleway</a> ·
  <a href="#demarrer">Démarrer</a> ·
  <a href="scaleway/README.md">Déployer</a> ·
  <a href="#avertissements">Avertissements</a>
</p>

---

## En bref

- **10 rapports** sous forme de pages HTML autonomes, avec schémas, sources et points à vérifier.
- **Cloud européen** : Mistral sur Scaleway, en région Paris. Architecture cible, modes d'inférence, coûts.
- **Usine d'IA sur site** : GPU NVIDIA reliés par InfiniBand, du simulateur ibsim à la fabric commutée.
- **Clusters GPU** : ordonnancement avec Slurm, POC exécuté sur fabric simulée.
- **4 produits Terraform** déployables depuis GitHub Actions (API Mistral, RAG, agents, analyse) sur un socle commun.
- **Sécurité par défaut** : instances privées, API en échec fermé, secrets dans Secret Manager, déploiement soumis à approbation.

<a id="rapports"></a>

## Rapports

> Les rapports sont des pages HTML autonomes. Ouvrez-les dans un navigateur, ou publiez le dépôt avec GitHub Pages (*Settings > Pages > Deploy from a branch*, dossier racine) : [`index.html`](index.html) sert alors de sommaire.

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

<a id="code-scaleway"></a>

## Code : IA souveraine sur Scaleway

Le dossier [`scaleway/`](scaleway/README.md) contient quatre produits Terraform déployables depuis GitHub Actions. Ils partagent le même socle : réseau privé, passerelle d'API compatible OpenAI et modèles Mistral. Seule la couche applicative change d'un produit à l'autre.

<p align="center">
  <img src="scaleway/docs/architecture-gateway.svg" alt="Architecture du socle commun : réseau privé, Public Gateway, passerelle d'API Mistral et inférence" width="85%">
</p>

| Produit | Pour quoi faire | Briques applicatives |
|---|---|---|
| [`gateway`](scaleway/products/gateway/README.md) | API Mistral compatible OpenAI pour vos applications | LiteLLM |
| [`rag`](scaleway/products/rag/README.md) | Discuter avec ses documents, réponses sourcées | Open WebUI, PostgreSQL + pgvector |
| [`agents`](scaleway/products/agents/README.md) | Construire des agents et des workflows, les appeler en API | Langflow, MCP Scaleway (option) |
| [`analytics`](scaleway/products/analytics/README.md) | Interroger ses données en français, tableaux de bord | ClickHouse, Superset, Open WebUI |

### Comment ça marche

```mermaid
flowchart LR
    G["GitHub Actions<br/>plan sur chaque PR<br/>apply après approbation"] --> T["Terraform<br/>un state par produit"]
    T --> S["Socle Scaleway, Paris<br/>réseau privé · Public Gateway<br/>passerelle LiteLLM · IAM · Secret Manager"]
    S --> I["Inférence Mistral<br/>Generative APIs · GPU + vLLM<br/>ou Managed Inference"]
    S --> P["Produits<br/>gateway · rag · agents · analytics"]
```

- **Validation :** la configuration passe `terraform validate` et `terraform fmt` hors ligne, avec le provider `scaleway/scaleway` 2.85.0. Aucun produit n'a encore été déployé.
- **Workflows :** ils sont dans `.github/workflows/`. Ils attendent les secrets décrits dans [`scaleway/README.md`](scaleway/README.md).
- **Serveur MCP :** `.mcp.json` configure le serveur MCP Scaleway en lecture seule pour Claude Code. Les identifiants viennent des variables d'environnement `SCW_*` et ne sont jamais stockés dans le dépôt.
- **Sécurité :** le déploiement est en échec fermé par défaut (la passerelle répond `403` tant que `allowed_api_cidrs` n'est pas renseigné). Les réglages de durcissement sont détaillés dans [`scaleway/README.md`](scaleway/README.md#sécurité-par-défaut).

<a id="demarrer"></a>

## Démarrer

**Lire les rapports :** clonez le dépôt et ouvrez [`index.html`](index.html) dans un navigateur, ou activez GitHub Pages.

**Déployer un produit sur Scaleway :**

```bash
cd scaleway
scw init                 # profil administrateur
./scripts/bootstrap.sh   # bucket de state + application IAM pour GitHub Actions
```

Enregistrez ensuite les secrets affichés dans GitHub, créez l'environnement `scaleway-prod` avec des *required reviewers*, puis lancez *Actions > sovereign-ai / terraform*. Toutes les étapes : **[scaleway/README.md](scaleway/README.md#déployer-un-produit)**.

## Technologies

| | Technologie | Rôle dans ce dépôt |
|---|---|---|
| <img src="https://cdn.simpleicons.org/scaleway/4F0599" width="22" alt=""> | [Scaleway](https://www.scaleway.com) | Cloud européen, région Paris : réseau privé, instances, Generative APIs, Managed Inference, bases managées |
| <img src="https://cdn.simpleicons.org/mistralai/FA520F" width="22" alt=""> | [Mistral AI](https://mistral.ai) | Modèles servis par la passerelle (Mistral Small 3.2 par défaut) |
| <img src="https://cdn.simpleicons.org/terraform/7B42BC" width="22" alt=""> | [Terraform](https://www.terraform.io) | Les quatre produits et leur socle commun |
| <img src="https://cdn.simpleicons.org/githubactions/2088FF" width="22" alt=""> | [GitHub Actions](https://docs.github.com/actions) | `fmt`, `validate` et `plan` sur chaque PR ; `apply`, `destroy` et copie des images après approbation |
| <img src="https://cdn.simpleicons.org/nvidia/76B900" width="22" alt=""> | [NVIDIA InfiniBand](https://www.nvidia.com/fr-fr/networking/products/infiniband/) | Usine d'IA sur site : Quantum-X800, ConnectX, Subnet Manager, UFM |
| | [Slurm](https://slurm.schedmd.com) | Ordonnancement des clusters GPU |
| | [LiteLLM](https://www.litellm.ai) | Passerelle d'API compatible OpenAI, clés et repli |
| | [Open WebUI](https://openwebui.com), [Langflow](https://www.langflow.org), [Superset](https://superset.apache.org) | Applications des produits `rag`, `agents` et `analytics` |

## Organisation

```
rapports/            pages HTML autonomes, par thème
  scaleway/          Mistral sur Scaleway
  nvidia-infiniband/ usine d'IA et fabric InfiniBand
  slurm/             clusters GPU
scaleway/            templates Terraform, schémas, scripts
  modules/           socle commun : platform, app-host, postgres
  products/          gateway, rag, agents, analytics
.github/workflows/   plan et apply Terraform, copie des images vers Scaleway
docs/assets/         bannière
index.html           sommaire des rapports (GitHub Pages)
```


<a id="architecture-deploiement"></a>

## Architecture de deploiement (branche infra/scaleway-mistral-test)

Une architecture IA souveraine a 3 niveaux est documentee sur la branche <code>infra/scaleway-mistral-test</code> :

| Niveau | Cible | Hebergement | Documentation |
|---|---|---|---|
| Confidentiel Defense | OIV, defense, secret industriel | On-premise air-gapped, Slurm + InfiniBand | <a href="docs/architecture/01-niveau-confidentiel-defense.md">doc</a> · <a href="docs/architecture/schemas/niveau-secret-infiniband.svg">schema</a> |
| Entreprise Cloud | ETI, grands comptes, secteur regule | Scaleway fr-par, Kubernetes, Mistral Compute | <a href="docs/architecture/02-niveau-entreprise-cloud.md">doc</a> |
| TPE/PME SaaS | TPE, PME, independants | Vibe Enterprise manage, Mistral API UE | <a href="docs/architecture/03-niveau-tpe-pme-saas.md">doc</a> |

Schemas : <a href="docs/architecture/schemas/architecture-globale.svg">architecture globale</a> · <a href="docs/architecture/schemas/flux-donnees.svg">flux de donnees</a>

Deploiement : <a href="docs/deploiement/llm-gateway-litellm.md">LiteLLM Gateway</a> · <a href="docs/deploiement/slurm-infiniband-onprem.md">Slurm InfiniBand on-prem</a> · <a href="docs/deploiement/scaleway-terraform.md">Terraform Scaleway</a>

Agent Vibe : <a href=".vibe/agents/souverain-architect.toml">souverain-architect</a>


<a id="avertissements"></a>

## Avertissements

- **Chiffres datés :** prix, stocks et versions ont été relevés à une date donnée. Vérifiez-les avant tout engagement.
- **Sources :** certaines pages officielles n'étaient pas lisibles depuis l'environnement de rédaction. Chaque rapport indique ses sources et ce qui reste à vérifier.
- **Mentions tierces :** voir [`NOTICE.md`](NOTICE.md).

## Contact

Questions, remarques ou corrections : ouvrez une **[issue](https://github.com/4math2379/Recherches-IA-Souveraine/issues)**.
