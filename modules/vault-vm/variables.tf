variable "gcp_project_id" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "vault-server"
}

variable "network_target_tag" {
  type = string
}

# Variables que vienen del módulo de storage
variable "gcs_bucket_name" {
  type = string
}

variable "kms_key_id" {
  type = string
}

variable "kms_key_ring_name" {
  type = string
}

variable "kms_key_name" {
  type = string
}

variable "instance_count" {
  description = "Número de instancias de Vault a crear."
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Tipo de máquina GCP para las instancias."
  type        = string
  default     = "e2-micro"
}

variable "is_dev_mode" {
  description = "Si es true, usa el script de instalación para modo desarrollo."
  type        = bool
  default     = false
}