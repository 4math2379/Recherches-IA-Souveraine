# IA souveraine sur Scaleway

Quatre produits d'IA packagés, hébergés chez Scaleway en région Paris et déployés depuis GitHub avec Terraform. Ils partagent le même socle : réseau privé, passerelle d'API compatible OpenAI et modèles Mistral. Seule la couche applicative change d'un produit à l'autre.

> **Aucun déploiement n'a été lancé.** Les quatre produits passent `terraform validate` et `terraform fmt` hors ligne, avec le provider `scaleway/scaleway` 2.85.0. Aucun `plan` ni `apply` n'a tourné contre un compte Scaleway.

## Catalogue

| Produit | Pour quoi faire | Briques applicatives | Services Scaleway en plus du socle | Ordre de coût mensuel* |
|---|---|---|---|---|
| [`gateway`](products/gateway/README.md) | API Mistral compatible OpenAI pour vos applications | LiteLLM | aucun | ≈ 20 € + tokens |
| [`rag`](products/rag/README.md) | Discuter avec ses documents, réponses sourcées | Open WebUI | PostgreSQL + pgvector, Object Storage | ≈ 60 € + base + tokens |
| [`agents`](products/agents/README.md) | Construire des agents et des workflows, les appeler en API | Langflow, MCP Scaleway (option) | PostgreSQL | ≈ 60 € + base + tokens |
| [`analytics`](products/analytics/README.md) | Interroger ses données en français, tableaux de bord | Superset, Open WebUI, MCP ClickHouse | Data Warehouse ClickHouse, PostgreSQL, Object Storage | ≈ 60 € + entrepôt + base + tokens |

\* Instances seules, prix horaires lus dans l'API Scaleway le 2026-10-07 : PLAY2-NANO 0,0275 €/h, PLAY2-MICRO 0,0551 €/h. La Public Gateway, les bases managées et le Data Warehouse sont à vérifier sur la page de tarifs Scaleway.

Icônes des schémas : [`@ultraviolet/icons`](https://www.npmjs.com/package/@ultraviolet/icons), le design system officiel de Scaleway (licence Apache 2.0).

## Organisation du code

```
scaleway/
  modules/
    platform/   socle : VPC, Public Gateway, passerelle IA (Caddy + LiteLLM), inférence, IAM
    app-host/   instance privée qui fait tourner un docker compose
    postgres/   PostgreSQL managé, endpoint privé, chiffré, sauvegardé
  products/
    gateway/    socle seul
    rag/        + Open WebUI, pgvector, bucket de documents
    agents/     + Langflow, PostgreSQL, MCP Scaleway en option
    analytics/  + ClickHouse, Superset, chat analyste, bucket de dépôt
  docs/         schémas d'architecture
  scripts/      bootstrap.sh (state et compte de déploiement)
```

Chaque produit est une racine Terraform indépendante, avec son propre state (`sovereign-ai/<produit>.tfstate`) et son propre réseau. Les produits peuvent donc coexister dans un même projet Scaleway.

## Le socle commun

![Socle](docs/architecture-gateway.svg)

| Composant | Service Scaleway | Rôle |
|---|---|---|
| Réseau | VPC, Private Network `172.16.32.0/22` | Toutes les instances sont privées, sans IP publique. DNS interne `<nom>.<réseau>.internal` |
| Entrée et sortie | Public Gateway `VPC-GW-S` | Seule IP publique : redirection de ports (PAT) 443/80, NAT sortant, bastion SSH sur le port 61000 |
| Passerelle IA | Instance `PLAY2-NANO`, Ubuntu 24.04 | Caddy (TLS automatique, un sous-domaine par application) et LiteLLM (API `/v1`, clé maître, alias, repli) |
| Inférence, au choix | Generative APIs, GPU Instance + vLLM, ou Managed Inference | Voir le tableau suivant |
| Identité | IAM : une application par usage | La passerelle ne peut appeler que Generative APIs, dans ce seul projet |
| Secrets | Secret Manager | Clé maître de la passerelle et mots de passe des produits |
| Images (option) | Container Registry `fr-par` | Copie des images pour ne plus dépendre de Docker Hub ou GHCR |

Adresses publiées :

- **API :** `https://api.<domaine>/v1` (aussi sur `https://<domaine>/v1` pour le produit `gateway`).
- **Application du produit :** `https://<domaine>`.
- **Superset (produit `analytics`) :** `https://bi.<domaine>`.

Les applications d'un produit appellent la passerelle en interne : `http://<prefixe>-gateway.<prefixe>-pn.internal:4000/v1`.

### Les trois modes d'inférence

| `inference_mode` | Ce qui tourne | Quand le choisir | Coût |
|---|---|---|---|
| `generative_api` (défaut) | Generative APIs, `mistral-small-3.2-24b-instruct-2506` | Démarrage, trafic irrégulier, et tant que les GPU sont en pénurie | Au token |
| `gpu_instance` | `L40S-1-48G` + vLLM, Mistral Small 3.2 quantifié en FP8 | Contrôle total, modèle affiné, données qui ne doivent pas quitter vos GPU | Environ 1,47 €/h |
| `managed_inference` | Managed Inference `L40S`, endpoint privé | GPU dédié sans exploiter vLLM soi-même | À l'heure, par nœud |

Avec `serverless_fallback = true`, la passerelle bascule sur Generative APIs si le backend dédié tombe. Mettez `false` si les données ne doivent jamais passer par une infrastructure partagée.

**État des stocks au 2026-10-07** (relevé avec `scw instance server-type list`) : toutes les instances GPU (L4, L40S, H100, B300) sont marquées *shortage* dans `fr-par-1`, `fr-par-2` et `pl-waw-2`. Côté Managed Inference, `L4` et `L40S` sont en stock inconnu et `H100` en rupture. C'est pour cela que le mode par défaut est serverless.

Tous les réglages du socle sont regroupés dans l'objet `platform` du fichier `env/prod.tfvars` de chaque produit. La liste complète, avec les valeurs par défaut, se trouve dans `modules/platform/variables.tf`.

## Déployer un produit

### 1. Une seule fois, pour tous les produits

```bash
scw init                       # profil administrateur
./scripts/bootstrap.sh         # bucket de state + application IAM pour GitHub Actions
```

Le script affiche les valeurs à enregistrer dans GitHub (*Settings > Secrets and variables > Actions*) :

- **Secrets :**
  - `SCW_ACCESS_KEY`
  - `SCW_SECRET_KEY`
  - `SCW_DEFAULT_ORGANIZATION_ID`
  - `SCW_DEFAULT_PROJECT_ID`
  - `HF_TOKEN` (facultatif)
- **Variable :** `TF_STATE_BUCKET`

Créez aussi l'environnement GitHub `scaleway-prod` et ajoutez-y des *required reviewers* : c'est cette approbation qui protège `apply` et `destroy`.

### 2. Configurer

Éditez `products/<produit>/env/prod.tfvars`. Ce fichier ne contient aucun secret. Les réglages à revoir en priorité :

- **`gateway_domain` :** votre domaine, par exemple `rag.example.fr`, avec deux enregistrements DNS A vers l'output `public_ip` : le domaine et `*.domaine`. Laissé vide, la passerelle utilise `<ip>.sslip.io`.
- **`allowed_api_cidrs` :** les plages d'adresses autorisées. Le filtre s'applique à l'API comme aux applications.
- **`bastion_allowed_cidrs` et `ssh_public_keys` :** l'accès SSH. Sans ces deux réglages, le bastion reste désactivé.

### 3. Lancer

- **Pull request :** chaque PR qui touche `scaleway/` lance `fmt`, puis `validate` et `plan` pour les quatre produits. Les plans s'affichent dans le résumé des jobs.
- **Apply ou destroy :** *Actions > sovereign-ai / terraform > Run workflow*, puis choisir le produit et l'action. L'exécution attend l'approbation de l'environnement `scaleway-prod`.

En local, sans CI :

```bash
cd products/rag
export AWS_ACCESS_KEY_ID=$SCW_ACCESS_KEY AWS_SECRET_ACCESS_KEY=$SCW_SECRET_KEY
terraform init -backend-config="bucket=<bucket>" -backend-config="key=sovereign-ai/rag.tfstate"
terraform plan -var-file=env/prod.tfvars
```

### 4. Récupérer un secret

```bash
scw secret version access $(terraform output -raw master_key_secret_id | cut -d/ -f2) revision=latest raw=true
```

## Souveraineté : ce qui reste hors de Scaleway

Tout ce qui sert les requêtes et stocke les données tourne chez Scaleway, en région Paris. Restent hors UE, uniquement au déploiement :

| Dépendance | Juridiction | Comment la retirer |
|---|---|---|
| Images Docker (GHCR, Docker Hub) | États-Unis | Workflow *mirror images*, puis `use_scaleway_registry = true` pour le socle et les variables `*_image` des produits pointées sur `rg.fr-par.scw.cloud/...` |
| Paquets Python (PyPI) pour Superset et le serveur MCP ClickHouse | États-Unis | Construire ces images une fois et les pousser dans Container Registry |
| Poids du modèle (Hugging Face), mode `gpu_instance` | États-Unis | Copier les poids dans Object Storage `fr-par` (évolution prévue) |
| Runners GitHub Actions | États-Unis | Runner auto-hébergé sur une instance Scaleway, ou GitLab auto-hébergé |
| Certificat TLS (Let's Encrypt) | États-Unis (ISRG) | Certificat d'une autorité européenne |
| sslip.io (sans domaine) | Service tiers | Renseigner `gateway_domain` |

La recherche web et la télémétrie sont désactivées dans Open WebUI et Langflow.

**SecNumCloud :** Scaleway n'est pas encore qualifié. Si un client public ou un OIV l'exige, ces produits ne suffisent pas.

## Points à vérifier avant la production

- **Premier déploiement :** aucun produit n'a encore tourné. Prévoyez un `apply` de recette par produit avant de le proposer à un client.
- **Managed Inference via l'endpoint privé :** l'URL et le certificat TLS de l'endpoint privé n'ont pas pu être testés.
- **Permissions IAM du compte de déploiement :** l'application GitHub a `IAMApplicationManager` et `IAMPolicyManager` au niveau de l'organisation, nécessaires pour créer les applications IAM des produits. Ces droits permettent en théorie de s'en octroyer d'autres.
- **Secrets dans le state :** clés API, mots de passe et clé maître sont dans le state Terraform et dans le `user_data` des instances. Le bucket de state doit rester privé.
- **Utilisateur des bases :** les applications utilisent l'utilisateur administrateur de leur PostgreSQL, parce qu'elles créent des extensions (pgvector). Créez des utilisateurs dédiés après le premier démarrage si votre politique l'exige.
- **Versions d'images :** `main`, `main-stable`, `latest` et `caddy:2` sont des versions mouvantes. Fixez-les à une version précise, voire à un digest.
- **Clés par application :** les produits utilisent la clé maître de la passerelle. Pour des clés par équipe et des budgets, donnez une base PostgreSQL à LiteLLM.
