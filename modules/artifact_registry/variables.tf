variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

variable "repo_name" {
  description = "repository name"
  type        = string
  default     = "my-repo"
}

variable "repo_description" {
  description = "repository description"
  type        = string
  default     = "desc"

}
