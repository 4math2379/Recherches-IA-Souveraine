# 🧪 Test rendu Mermaid sur GitHub

Ce fichier teste si GitHub rend correctement les blocs `mermaid` dans les fichiers `.md`.

## Schéma test — Architecture 3 niveaux

```mermaid
flowchart TB
    subgraph NIVEAU["Architecture IA Souveraine"]
        C["👤 Client"] --> GW["🔀 LiteLLM Gateway"]
        GW --> M["🧠 Mistral LLM"]
        M --> R["✅ Réponse"]
    end
    style NIVEAU fill:#e3f2fd,stroke:#1565c0
```

## Si tu vois un diagramme ci-dessus → Mermaid fonctionne ✅
## Si tu vois juste du texte brut → il faut changer d'approche ❌
