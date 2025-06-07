# BackendInfrastructure

## How to construct and destroy the infrastructure?

When creating the infrastructure, make sure that you have created a .env file on the root and a service account with the structure specified on the following sections. Once the requirements are meet, the next step is execute the script `apply_terraform.sh`. This script receives the environment you want to creat through params. The environment accepted values are `dev`, `staging`, `prod`. Each environment has different types of vm defined and a topoly to assure fault tolerance on the vault.

## Terraform Service Account and Artifact Registry Roles

### A. Service Account to Execute Terraform

In order for Terraform to create all the necessary resources (VMs, Buckets, KMS Keys, IAM Roles, Artifact Registry repositories, etc.), the **Service Account used to run `terraform apply`** must have the following **project-level IAM roles**:

- `roles/compute.admin`: To create and manage VMs.
- `roles/storage.admin`: To create and manage GCS buckets.
- `roles/cloudkms.admin`: To manage KeyRings and CryptoKeys in KMS.
- `roles/iam.serviceAccountAdmin`: To create and manage Service Accounts.
- `roles/iam.serviceAccountUser`: To use Service Accounts.
- `roles/resourcemanager.projectIamAdmin`: ⚠️ Highly privileged. Needed to assign IAM roles to other service accounts (e.g., granting GCS and KMS access to the Vault SA).
- `roles/artifactregistry.admin`: To create and manage Artifact Registry repositories.

You can create this Service Account and assign the necessary roles using `gcloud`:

```bash
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
```

> 🔐 **Note**: This script (`create_sa.sh`) must be run with **a user who has project administrator privileges**.
>
> It also requires a `.env` file inside the `scripts/` directory with the following content:

```env
PROJECT_ID=arquisoftv-microservice
SA_NAME=terraform-backend-executor
AWS_ACCESS_KEY_ID="anaccesskey"
AWS_SECRET_ACCESS_KEY="asecretkey"
AWS_REGION="us-west-2"
```

---

## 📦 What Are `artifactregistry.reader` and `artifactregistry.writer` Roles Used For?

These roles are **not needed by Terraform**, but are essential for the **Service Account used by your application or CI/CD pipeline** (e.g., `registry-editor` in your code).

### 🔸 `roles/artifactregistry.writer` (Writer)

- Required by the system that **builds and pushes Docker images**.
- Example: your CI/CD pipeline (GitHub Actions, GitLab CI, Jenkins) needs this role to run:

  ```bash
  docker push gcr.io/your-project/your-repo/your-image:latest
  ```

- It grants **upload permissions** to Artifact Registry.

### 🔸 `roles/artifactregistry.reader` (Reader)

- Required by the system that **deploys or runs your container**.
- Example: services like **GKE**, **Cloud Run**, or a **Compute Engine VM** need this role to:

  ```bash
  docker pull gcr.io/your-project/your-repo/your-image:latest
  ```

- It grants **download permissions** from Artifact Registry.

---

## 🔐 HashiCorp Vault for Production Environments

To deploy HashiCorp Vault securely and reliably in a production setting, we adopt a more robust infrastructure by leveraging **managed cloud services for storage and encryption**:

---

### 1. 📦 Storage Backend with Google Cloud Storage (GCS)

Instead of storing encrypted Vault data in the VM's local disk or memory, we use **Google Cloud Storage (GCS)** as the **storage backend**.

#### ✅ Why GCS?

- **Durable**: Highly available and replicated across zones.
- **Managed**: No need to worry about infrastructure or backups.
- **Cost-efficient**: Pay only for what you use.

#### 🔧 How Vault uses GCS:

Vault stores its **encrypted data** (keys, secrets, leases, etc.) in a GCS bucket. The bucket itself doesn't hold plain data—Vault encrypts everything before writing. GCS is simply the storage layer.

---

### 2. 🔓 Auto-Unseal with Google Cloud KMS

By default, when Vault starts, it is in a **sealed state**. This means that the master key used to decrypt data is itself encrypted and must be **"unsealed"** before the Vault can operate.

#### 🧱 Traditional Method:

- Requires **multiple operators** to enter key shards (using Shamir’s Secret Sharing).
- Not scalable or practical in automated environments.

#### 🚀 Auto-Unseal Mechanism:

Instead of manually unsealing Vault, we enable **Auto-Unseal** using **Google Cloud Key Management Service (KMS)**.

#### ✅ How It Works:

- Vault stores an encrypted version of its master key in GCS.
- On startup, Vault contacts **Cloud KMS** to decrypt that key securely.
- This allows Vault to **unseal itself automatically**—ideal for **automation, high availability, and disaster recovery**.

#### 🔐 Benefits of Auto-Unseal with KMS:

- **Hands-off unsealing**—no human intervention required.
- **Integrated with GCP IAM**—access can be tightly controlled.
- **Secure key management**—your master key never leaves KMS unencrypted.

### 🧩 Summary

| Component       | Service Used         | Purpose                           |
| --------------- | -------------------- | --------------------------------- |
| Storage Backend | Google Cloud Storage | Durable and managed Vault storage |
| Auto-Unseal     | Google Cloud KMS     | Automated, secure unsealing       |

This setup makes Vault **cloud-native, scalable, and automation-friendly**, which is critical for secure production environments.

---
