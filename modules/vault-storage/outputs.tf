output "gcs_bucket_name" {
  description = "Nombre del bucket de GCS para el backend de Vault."
  value       = google_storage_bucket.vault_storage.name
}

output "kms_key_id" {
  description = "ID completo de la clave de KMS para el unseal."
  value       = google_kms_crypto_key.vault_unseal_key.id
}

output "kms_key_ring_name" {
  description = "Nombre del keyring de KMS."
  value       = google_kms_key_ring.vault_keyring.name
}

output "kms_key_name" {
  description = "Nombre de la clave de KMS."
  value       = google_kms_crypto_key.vault_unseal_key.name
}