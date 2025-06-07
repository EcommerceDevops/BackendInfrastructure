output "firewall_rule_name" {
  description = "Nombre de la regla de firewall creada."
  value       = google_compute_firewall.vault_firewall.name
}