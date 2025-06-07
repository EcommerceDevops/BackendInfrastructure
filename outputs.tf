output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "region" {
  value       = var.region
  description = "GCloud Region"
}

output "vault_region" {
  value       = var.vault_region
  description = "GCloud Region"
}

output "address_vault" {
  value       = module.vault_vm.vault_address
  description = "URL of the Vault instance"
}

output "ip_vault" {
  value       = module.vault_vm.vault_ip_address
  description = "IP address of the Vault instance"
}