# 🛡️ Conformité NIS2 · DORA · AI Act européen

---

## 🇪🇺 NIS2 — Cybersécurité

| Exigence | Implémentation |
|----------|----------------|
| Gestion des risques | Architecture 3 niveaux, segmentation |
| Sécurité réseau | VPC privé, VPN, IDS/IPS |
| Gestion incidents | Notification 72h, SIEM |
| Continuité | HA, PRA/PCA documenté |
| Chaîne fourniture | Fournisseurs UE uniquement |
| Auth forte | MFA, SSO |

---

## 🏦 DORA — Secteur financier

| Exigence | Implémentation |
|----------|----------------|
| Gouvernance | RSSI dédié |
| Risques ICT | Cartographie, stress tests |
| Tests résilience | Pentest, chaos engineering |
| Dépendances | Mistral + Scaleway UE, contrats DORA |

---

## 🤖 AI Act européen (2024/1689)

| Catégorie | Notre plateforme | Obligations |
|-----------|-----------------|-------------|
| Risque minimal (chatbot) | ✅ Vibe standard | Transparence utilisateur |
| Haut risque (santé, crédit) | Si client concerné | Doc, logs, supervision humaine |
| Interdit (social scoring) | ❌ Non proposé | — |

| Obligation AI Act | Application |
|-------------------|-------------|
| Transparence | Info "vous parlez à une IA" |
| Documentation | Fiche modèle Mistral |
| Logs/traçabilité | LiteLLM audit logs, 6 mois min |
| Supervision humaine | Option human-in-the-loop |
| Robustesse | Architecture 3 niveaux, tests |

---

## 📊 Matrice conformité par niveau

| Réglementation | 🥇 Secret | 🥈 Entreprise | 🥉 TPE/PME |
|---------------|:---------:|:------------:|:---------:|
| RGPD | ✅ | ✅ | ✅ |
| NIS2 | ✅ | ✅ | ⚠️ via CCL |
| DORA | ✅ | ✅ | ⚠️ via CCL |
| AI Act minimal | ✅ | ✅ | ✅ |
| AI Act haut risque | ✅ | ✅ | ⚠️ |
| SecNumCloud | on-prem | ✅ | ✅ |
| Cloud Act US | ✅ Immune | ✅ Immune | ✅ Immune |
