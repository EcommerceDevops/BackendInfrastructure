locals {
  # Central configuration map for all environments
  environments = {
    # Configuration for the PRODUCTION environment
    prod = {
      instance_count = 3
      machine_type   = "e2-small" # Slightly more powerful for prod
      is_dev_mode    = false
      enable_storage = true
    }
    # Configuration for the STAGING environment
    staging = {
      instance_count = 2 # In staging we want to test the cluster but with fewer nodes
      machine_type   = "e2-micro"
      is_dev_mode    = false
      enable_storage = true
    }
    # Configuration for the DEVELOPMENT environment
    dev = {
      instance_count = 1
      machine_type   = "e2-micro" # Cheapest option for dev
      is_dev_mode    = true       # Key! Will use Vault's dev mode
      enable_storage = false      # Dev mode doesn’t require persistent backend
    }
  }

  # Get the configuration for the currently selected workspace.
  # If the workspace doesn’t exist in the map (e.g. "default"), use the "dev" config.
  env_config = lookup(local.environments, terraform.workspace, local.environments.dev)
}

locals {
  vault_network_tag = "vault-server-${terraform.workspace}"
}

module "artifact_registry" {
  source           = "./modules/artifact_registry"
  region           = var.region
  project_id       = var.project_id
  repo_name        = var.repo_name
  repo_description = var.repo_description
}

module "backend" {
  source         = "./modules/s3_backend"
  s3_bucket_name = var.s3_bucket_name
}

module "vault_storage" {
  source         = "./modules/vault-storage"
  count          = local.env_config.enable_storage ? 1 : 0
  gcp_project_id = var.project_id
  gcp_region     = var.vault_region
}

module "vault_networking" {
  source = "./modules/vault-networking"

  gcp_project_id      = var.project_id
  firewall_target_tag = local.vault_network_tag
}

# The VM module now receives its parameters from the configuration map
module "vault_vm" {
  source = "./modules/vault-vm"

  # Pass the environment-specific parameters
  instance_count = local.env_config.instance_count
  machine_type   = local.env_config.machine_type
  is_dev_mode    = local.env_config.is_dev_mode

  # Storage data may not exist, so we use a condition.
  # The 'splat' operator [*] converts the resource with count=0 into an empty list.
  gcs_bucket_name   = length(module.vault_storage) > 0 ? module.vault_storage[0].gcs_bucket_name : null
  kms_key_id        = length(module.vault_storage) > 0 ? module.vault_storage[0].kms_key_id : null
  kms_key_ring_name = length(module.vault_storage) > 0 ? module.vault_storage[0].kms_key_ring_name : null
  kms_key_name      = length(module.vault_storage) > 0 ? module.vault_storage[0].kms_key_name : null


  gcp_project_id     = var.project_id
  gcp_region         = var.vault_region
  network_target_tag = "vault-server-${terraform.workspace}" # Unique tag per environment
}
