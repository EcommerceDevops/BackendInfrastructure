#!/bin/bash


cd "$(dirname "${BASH_SOURCE[0]}")"/..

source .env

# Crear el Service Account
gcloud iam service-accounts create ${SA_NAME} \
  --display-name="Terraform Executor SA" \
  --project=${PROJECT_ID}

# Asignar los roles
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/compute.admin"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/storage.admin"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/cloudkms.admin"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/iam.serviceAccountAdmin"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/iam.serviceAccountUser"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/resourcemanager.projectIamAdmin"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member="serviceAccount:${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" --role="roles/artifactregistry.admin"

gcloud iam service-accounts keys create terraform-backend-key.json --iam-account="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"