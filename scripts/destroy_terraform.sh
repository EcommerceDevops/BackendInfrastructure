#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Go to the script's directory
cd "$(dirname "${BASH_SOURCE[0]}")"/..

# --- Environment Selection ---
echo "--- Environment Selection ---"

# Get the environment from the first argument
ENV=$1

# Validate the provided environment
if [ -z "$ENV" ]; then
    echo "ERROR: No environment specified. Please provide 'dev', 'staging', or 'prod'."
    exit 1
elif [ "$ENV" != "dev" ] && [ "$ENV" != "staging" ] && [ "$ENV" != "prod" ]; then
    echo "ERROR: Invalid environment '$ENV'. Valid options are 'dev', 'staging', or 'prod'."
    exit 1
fi

echo "--- Terraform Workspace Selection ---"
echo "🔹 Selecting Terraform workspace: $ENV..."
terraform workspace select "$ENV"

# --- Infrastructure Destruction ---
echo "--- Infrastructure Destruction ---"

VAR_FILE="terraform.tfvars"

echo "🔹 Destroying infrastructure for environment: $ENV..."
terraform destroy \
  -target=module.vault_storage \
  -target=module.vault_networking \
  -target=module.vault_vm \
  -var-file="$VAR_FILE" \
  -auto-approve

echo "✅ Infrastructure for environment '$ENV' has been destroyed."