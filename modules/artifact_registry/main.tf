resource "google_artifact_registry_repository" "microservice_registry" {
  location      = var.region
  repository_id = var.repo_name
  description   = var.repo_description
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}

resource "google_service_account" "custom_sa" {
  account_id   = "registry-editor" # Nombre corto (sin dominio)
  display_name = "Cuenta de servicio para Microservicios"
}

resource "google_project_iam_member" "artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.custom_sa.email}"
}

resource "google_project_iam_member" "artifact_registry_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.custom_sa.email}"
}
