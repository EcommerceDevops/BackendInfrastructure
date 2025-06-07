# 1. Bucket de Google Cloud Storage para el backend de Vault
resource "google_storage_bucket" "vault_storage" {
  project       = var.gcp_project_id
  name          = "${var.gcp_project_id}-vault-storage-backend" # Nombre único globalmente
  location      = var.gcp_region
  force_destroy = true // Para desarrollo, facilita la destrucción
}

# 2. KeyRing de KMS para la clave de Auto-Unseal
resource "google_kms_key_ring" "vault_keyring" {
  project  = var.gcp_project_id
  name     = "vault-unseal-keyring"
  location = var.gcp_region
}

# 3. La CryptoKey de KMS que se usará para el Auto-Unseal
resource "google_kms_crypto_key" "vault_unseal_key" {
  name     = "vault-unseal-key"
  key_ring = google_kms_key_ring.vault_keyring.id
  purpose  = "ENCRYPT_DECRYPT"
}