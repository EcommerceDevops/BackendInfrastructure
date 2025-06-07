# 1. Service Account for Vault Server
resource "google_service_account" "vault_server_sa" {
  project      = var.gcp_project_id
  account_id   = "vault-server-sa"
  display_name = "Vault Server Service Account"
}

# 2. Access permissions for the Vault Service Account to access GCS and KMS
#    Estos recursos SÓLO se crearán si NO estamos en modo de desarrollo.
resource "google_storage_bucket_iam_member" "vault_sa_gcs_access" {
  # CORRECCIÓN: Añadir 'count' para hacer este recurso condicional.
  count  = var.is_dev_mode ? 0 : 1
  bucket = var.gcs_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.vault_server_sa.email}"
}

# 3. Access permissions for the Vault Service Account to use KMS for encryption/decryption
resource "google_kms_crypto_key_iam_member" "vault_sa_kms_access" {
  # CORRECCIÓN: Añadir 'count' para hacer este recurso condicional.
  count         = var.is_dev_mode ? 0 : 1
  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.vault_server_sa.email}"
}

# 4. Compute Instance for Vault Server
resource "google_compute_instance" "vault_server" {
  count        = var.instance_count
  project      = var.gcp_project_id
  zone         = "${var.gcp_region}-a"
  name         = "${var.instance_name}-${terraform.workspace}-${count.index}"
  machine_type = var.machine_type
  tags         = [var.network_target_tag]

  boot_disk {
    initialize_params { image = "debian-cloud/debian-11" }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.vault_server_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = templatefile(
    var.is_dev_mode ? "${path.module}/scripts/install-vault-dev.sh" : "${path.module}/scripts/install-vault-prod.sh",
    {
      GCS_BUCKET_NAME = var.gcs_bucket_name
      KMS_PROJECT     = var.gcp_project_id
      KMS_REGION      = var.gcp_region
      KMS_KEY_RING    = var.kms_key_ring_name
      KMS_KEY_NAME    = var.kms_key_name
    }
  )

  # CORRECCIÓN FINAL:
  # Eliminamos la lógica condicional '? :'.
  # Simplemente listamos los recursos. Terraform sabe ignorar la dependencia
  # si el 'count' de estos recursos es 0.
  # La referencia ahora es al recurso completo, que es una lista.
  depends_on = [
    google_storage_bucket_iam_member.vault_sa_gcs_access,
    google_kms_crypto_key_iam_member.vault_sa_kms_access,
  ]
}