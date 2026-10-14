#!/usr/bin/env bash
# One-time setup, run by a human with an admin Scaleway profile (scw init).
# One state bucket and one CI identity serve every product (gateway, rag, agents, analytics).
#  1. Object Storage bucket (versioned) for the Terraform state, in fr-par.
#  2. IAM application + API key used by GitHub Actions to run Terraform.
# Prints the values to store as GitHub secrets. Nothing is written to disk.
set -euo pipefail

PREFIX="${PREFIX:-souverain}"
REGION="${REGION:-fr-par}"
PROJECT_ID="${SCW_DEFAULT_PROJECT_ID:-$(scw config get default-project-id)}"
BUCKET="${BUCKET:-${PREFIX}-tfstate-${PROJECT_ID:0:8}}"

echo "Project: $PROJECT_ID  Region: $REGION  State bucket: $BUCKET"
read -r -p "Continue? [y/N] " ok
[[ "$ok" == "y" ]] || exit 1

scw object bucket create name="$BUCKET" region="$REGION" enable-versioning=true project-id="$PROJECT_ID"

APP_ID=$(scw iam application create name="${PREFIX}-github-terraform" \
  description="Terraform from GitHub Actions" -o json | jq -r .id)

# Project-scoped rights for the stack, plus the organization-scoped IAM rights
# Terraform needs to create the gateway's own IAM application and policy.
scw iam policy create name="${PREFIX}-github-terraform" application-id="$APP_ID" \
  rules.0.project-ids.0="$PROJECT_ID" \
  rules.0.permission-set-names.0=InstancesFullAccess \
  rules.0.permission-set-names.1=VPCFullAccess \
  rules.0.permission-set-names.2=VPCGatewayFullAccess \
  rules.0.permission-set-names.3=IPAMFullAccess \
  rules.0.permission-set-names.4=InferenceFullAccess \
  rules.0.permission-set-names.5=SecretManagerFullAccess \
  rules.0.permission-set-names.6=ObjectStorageFullAccess \
  rules.0.permission-set-names.7=ContainerRegistryFullAccess \
  rules.0.permission-set-names.8=BlockStorageFullAccess \
  rules.0.permission-set-names.9=SSHKeysFullAccess \
  rules.0.permission-set-names.10=RelationalDatabasesFullAccess \
  rules.0.permission-set-names.11=DataWarehouseFullAccess \
  rules.0.permission-set-names.12=PrivateNetworksFullAccess \
  rules.1.organization-id="$(scw config get default-organization-id)" \
  rules.1.permission-set-names.0=IAMApplicationManager \
  rules.1.permission-set-names.1=IAMPolicyManager \
  rules.1.permission-set-names.2=ProjectReadOnly >/dev/null

KEY_JSON=$(scw iam api-key create application-id="$APP_ID" default-project-id="$PROJECT_ID" \
  description="GitHub Actions" -o json)

cat <<EOF

Add these to the GitHub repository (Settings > Secrets and variables > Actions):
  secret   SCW_ACCESS_KEY              $(jq -r .access_key <<<"$KEY_JSON")
  secret   SCW_SECRET_KEY              (shown once below, copy it now)
  secret   SCW_DEFAULT_ORGANIZATION_ID $(scw config get default-organization-id)
  secret   SCW_DEFAULT_PROJECT_ID      $PROJECT_ID
  variable TF_STATE_BUCKET             $BUCKET

$(jq -r .secret_key <<<"$KEY_JSON")
EOF
