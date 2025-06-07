resource "google_compute_firewall" "vault_firewall" {
  project = var.gcp_project_id
  name    = "allow-vault-access-${var.firewall_target_tag}"
  network = var.network_name

  allow {
    protocol = "tcp"
    ports    = ["8200"]
  }

  source_ranges = var.source_ranges
  target_tags   = [var.firewall_target_tag]
}