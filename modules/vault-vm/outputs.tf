output "vault_address" {
  description = "La dirección pública del servidor de Vault. Se accede vía http://<IP>:8200"
  value = [for ip in google_compute_instance.vault_server[*].network_interface[0].access_config[0].nat_ip : "http://${ip}:8200"]
}

output "vault_ip_address" {
  description = "La dirección ip pública del servidor de Vault."
  value       = google_compute_instance.vault_server[*].network_interface[0].access_config[0].nat_ip
}

output "vault_initialization_command" {
  description = "Conéctate por SSH y corre 'vault operator init' para obtener las claves y el token raíz."
  value       = "ssh a la vm y ejecutar: export VAULT_ADDR=\"http://127.0.0.1:8200\" && vault operator init"
}