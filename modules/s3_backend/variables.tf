variable "s3_bucket_name" {
  description = "Nombre del bucket S3 para almacenar el estado de Terraform"
  type        = string
  default     = "terraform-microservice-state-bucket"
}