# Deploiement LLM Gateway — LiteLLM + Mistral

> Point d'entree unique pour tous les appels LLM : quotas, routing, cache, fallback.

---

## Docker Compose (TPE/PME & Entreprise)

### docker-compose.yml

```yaml
version: "3.9"
services:
  litellm:
    image: ghcr.io/berriai/litellm:latest
    ports:
      - "4000:4000"
    environment:
      - DATABASE_URL=postgres://litellm:password@postgres:5432/litellm
      - MISTRAL_API_KEY=${MISTRAL_API_KEY}
      - LITELLM_MASTER_KEY=${LITELLM_MASTER_KEY}
    volumes:
      - ./config.yaml:/app/config.yaml
    command: ["--config", "/app/config.yaml", "--port", "4000"]
    depends_on:
      - postgres
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: litellm
      POSTGRES_PASSWORD: password
      POSTGRES_DB: litellm
    volumes:
      - litellm_db:/var/lib/postgresql/data
volumes:
  litellm_db:
```

### config.yaml — Configuration Mistral

```yaml
model_list:
  - model_name: mistral-large
    litellm_params:
      model: mistral/mistral-large-latest
      api_key: os.environ/MISTRAL_API_KEY
      api_base: https://api.mistral.ai/v1
  - model_name: mistral-medium
    litellm_params:
      model: mistral/mistral-medium-latest
      api_key: os.environ/MISTRAL_API_KEY
  - model_name: codestral
    litellm_params:
      model: mistral/codestral-latest
      api_key: os.environ/MISTRAL_API_KEY
  # Self-hosted on-prem (niveau Confidentiel Defense)
  - model_name: mistral-local
    litellm_params:
      model: openai/mistral-large-3
      api_base: http://vllm-internal:8000/v1
litellm_settings:
  drop_params: True
  cache: True
general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY
  store_audit_logs: True
```

## Securite

| Mesure | Config |
|--------|--------|
| Auth | Cle master + cles virtuelles par client |
| TLS | Ingress nginx/traefik |
| Reseau | NetworkPolicy K8s (whitelist) |
| Logs | Audit logs locaux uniquement |
| Secrets | K8s Secrets ou Vault on-prem |

## Connexion Vibe vers LiteLLM

```json
{
  "model": "mistral-large",
  "api_base": "https://litellm.client-ccl.fr/v1",
  "api_key": "sk-...cle-virtuelle-client..."
}
```
