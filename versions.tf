terraform {

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.37.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.0.0-beta2"
    }
  }

  required_version = ">= 1.11"
}

provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project_id
  region      = var.region
}

provider "aws" {}
