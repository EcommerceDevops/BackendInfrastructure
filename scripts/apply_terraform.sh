#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Go to the script's directory
cd "$(dirname "${BASH_SOURCE[0]}")"/..

source .env

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

# --- Terraform Configuration ---
echo "--- Terraform Configuration ---"

VAR_FILE="terraform.tfvars"

# Check if Terraform is already initialized
if [ ! -d ".terraform" ]; then
    echo "🔹 Initializing Terraform..."
    terraform init
else
    echo "✅ Terraform is already initialized. Skipping init..."
fi

terraform init -input=false -backend=false > /dev/null

# Format code
echo "🔹 Running terraform fmt..."
terraform fmt

# Validate configuration
echo "🔹 Validating configuration..."
terraform validate

# --- Infrastructure Deployment ---
echo "--- Infrastructure Deployment ---"

# Check if machines are already created
EXISTING_MACHINES=$(terraform state list | grep "google_container_node_pool.primary_nodes" || true)

if [ -n "$EXISTING_MACHINES" ]; then
    echo "✅ Node pools already created. Skipping terraform apply..."
else
    # Show the plan
    echo "🔹 Generating plan..."
    terraform plan -var-file="$VAR_FILE"

    # Apply changes
    echo "🔹 Applying changes..."
    terraform apply -auto-approve -var-file="$VAR_FILE"
fi

# Get and display IPs and names of machines
echo "🔹 Retrieving output..."
terraform output

echo "✅ Infrastructure ready!"