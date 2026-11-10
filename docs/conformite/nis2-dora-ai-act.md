# Conformite NIS2 · DORA · AI Act europeen

---

## NIS2 — Cybersecurite

| Exigence | Implementation |
|----------|----------------|
| Gestion des risques | Architecture 3 niveaux, segmentation |
| Securite reseau | VPC prive, VPN, IDS/IPS |
| Gestion incidents | Notification 72h, SIEM |
| Continuite | HA, PRA/PCA documente |
| Chaine fourniture | Fournisseurs UE uniquement |
| Auth forte | MFA, SSO |

## DORA — Secteur financier

| Exigence | Implementation |
|----------|----------------|
| Gouvernance | RSSI dedie |
| Risques ICT | Cartographie, stress tests |
| Tests resilience | Pentest, chaos engineering |
| Dependances | Mistral + Scaleway UE, contrats DORA |

## AI Act europeen (2024/1689)

| Categorie | Notre plateforme | Obligations |
|-----------|-----------------|-------------|
| Risque minimal (chatbot) | Vibe standard | Transparence utilisateur |
| Haut risque (sante, credit) | Si client concerne | Doc, logs, supervision humaine |
| Interdit (social scoring) | Non propose | — |

| Obligation AI Act | Application |
|-------------------|-------------|
| Transparence | Info "vous parlez a une IA" |
| Documentation | Fiche modele Mistral |
| Logs/tracabilite | LiteLLM audit logs, 6 mois min |
| Supervision humaine | Option human-in-the-loop |
| Robustesse | Architecture 3 niveaux, tests |

## Matrice conformite par niveau

| Reglementation | Secret | Entreprise | TPE/PME |
|---------------|--------|-----------|---------|
| RGPD | Oui | Oui | Oui |
| NIS2 | Oui | Oui | Via CCL |
| DORA | Oui | Oui | Via CCL |
| AI Act minimal | Oui | Oui | Oui |
| AI Act haut risque | Oui | Oui | Selon usage |
| SecNumCloud | on-prem | Oui | Oui |
| Cloud Act US | Immune | Immune | Immune |
