# 🏪 Niveau 3 — TPE/PME SaaS
> Vibe Enterprise managé par CCL Consulting

---

## ☁️ Architecture

```
CLIENT (navigateur)
    │ HTTPS TLS 1.3
    ▼
┌────────────────────────────┐
│   INFRA CCL (managée)       │
│  ┌──────────────────────┐  │
│  │ LiteLLM Gateway       │  │  ← quotas/client
│  └──────────┬───────────┘  │
│  ┌──────────┴───────────┐  │
│  │ Vibe Enterprise       │  │  ← workspaces isolés
│  └──────────┬───────────┘  │
│  ┌──────────┴───────────┐  │
│  │ Mistral API (UE)      │  │  ← DPA RGPD
│  └──────────────────────┘  │
│   Hébergé Scaleway France 🇫🇷│
└────────────────────────────┘
```

---

## ✨ Offre client

- Vibe Pro/Team avec agents et connecteurs MCP
- Mistral Large via API, hébergé UE
- Workspace isolé par client
- DPA RGPD signé
- Support CCL en français
- Aucune complexité technique

---

## 💰 Tarification

| Offre | Prix | Inclus |
|-------|------|--------|
| Vibe TPE | 29,99€/user/mois | Vibe Team + Mistral API + support |
| Vibe PME | 49,99€/user/mois | + connecteurs avancés + support prioritaire |
| Vibe PME+ | Sur devis | Workspace dédié, DPA perso, SLA |
