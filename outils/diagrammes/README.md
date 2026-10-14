# Génération des schémas d'architecture

Les schémas de `scaleway/docs/` et des rapports utilisent les icônes produits officielles de Scaleway, issues du paquet npm [`@ultraviolet/icons`](https://www.npmjs.com/package/@ultraviolet/icons) (licence Apache 2.0, voir `NOTICE.md`).

| Fichier | Rôle |
|---|---|
| `uv2svg.mjs` | Convertit les composants React `ProductIcon` du paquet en SVG simples (Node.js, aucune dépendance) |
| `scaleway-icons.json` | Les icônes déjà converties utilisées par les schémas |
| `gateway_diagram.py` | Schéma du produit `gateway` (le socle) |
| `product_diagram.py` | Schémas des produits `rag`, `agents` et `analytics` |

## Régénérer

```bash
# 1. (optionnel) extraire de nouvelles icônes
mkdir -p /tmp/uv && cd /tmp/uv
npm pack @ultraviolet/icons && tar xzf ultraviolet-icons-*.tgz
node uv2svg.mjs /tmp/uv/package/dist/components/ProductIcon/__generated__ scaleway-icons.json \
  Instance InstanceGpu GenerativeApi Inference Vpc PublicGateway SecretManager ObjectStorage \
  Registry Iam Cockpit PostgresqlMysql SecurityGroup Terraform AuditTrail DataWarehouse Containers

# 2. schémas : "static" pour un SVG autonome, "vars" pour un SVG qui suit les variables CSS d'une page
python3 gateway_diagram.py scaleway-icons.json static ../../scaleway/docs/architecture-gateway.svg
for p in rag agents analytics; do
  python3 product_diagram.py scaleway-icons.json $p static ../../scaleway/docs/architecture-$p.svg
done
```
