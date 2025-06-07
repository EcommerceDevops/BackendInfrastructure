variable "gcp_project_id" {
  description = "El ID del proyecto de GCP."
  type        = string
}

variable "network_name" {
  description = "Nombre de la red VPC a la que se aplicará la regla."
  type        = string
  default     = "default"
}

variable "source_ranges" {
  description = "Lista de rangos de IP de origen permitidos."
  type        = list(string)
  default     = ["0.0.0.0/0"] # Abierto por defecto, ¡restringir en producción!
}

variable "firewall_target_tag" {
  description = "La etiqueta de red que identifica a las VMs de Vault."
  type        = string
}