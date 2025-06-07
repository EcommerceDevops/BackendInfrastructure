variable "project_id" {
  description = "project id"
  type        = string
}

variable "region" {
  description = "region"
  default     = "us-central1"
  type        = string
}

variable "vault_region" {
  description = "region for the VM"
  default     = "us-central1"
  type        = string

}

variable "repo_name" {
  description = "repo_name"
  default     = "name"
  type        = string
}

variable "repo_description" {
  description = "repo_description"
  default     = "Repository for ecommerce artifacts"
  type        = string
}

variable "credentials_file" {
  description = "value of the credentials file"
  type        = string
  default     = "terraform-backend-key.json"
}

variable "s3_bucket_name" {
  description = "Bucket name for storing Terraform state"
  type        = string
  default     = "terraform-ecommerce-state-bucket"
}