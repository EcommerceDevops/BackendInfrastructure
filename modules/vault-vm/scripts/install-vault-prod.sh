#!/bin/bash
# scripts/install-vault-prod.sh

# Actualizar e instalar dependencias
sudo apt-get update
sudo apt-get install -y wget gpg unzip

# Instalar Vault
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

# Crear el usuario y directorio para Vault
sudo useradd --system --home /etc/vault.d --shell /bin/false vault
sudo mkdir -p /etc/vault.d
sudo chown -R vault:vault /etc/vault.d

# Crear el archivo de configuración de Vault desde la plantilla
cat << EOF > /etc/vault.d/vault.hcl
ui = true

storage "gcs" {
  bucket = "${GCS_BUCKET_NAME}"
  ha_enabled = "true"
}

seal "gcpckms" {
  project     = "${KMS_PROJECT}"
  region      = "${KMS_REGION}"
  key_ring    = "${KMS_KEY_RING}"
  crypto_key  = "${KMS_KEY_NAME}"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true" # Para producción real, deberías configurar TLS
}

api_addr = "http://$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip):8200"
cluster_addr = "http://$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip):8200"
EOF

sudo chown vault:vault /etc/vault.d/vault.hcl
sudo chmod 640 /etc/vault.d/vault.hcl

# Crear el archivo de servicio de systemd para Vault
cat << EOF > /etc/systemd/system/vault.service
[Unit]
Description="HashiCorp Vault - A tool for managing secrets"
Documentation=https://www.vaultproject.io/docs/
Requires=network-online.target
After=network-online.target

[Service]
User=vault
Group=vault
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/vault server -config=/etc/vault.d/vault.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitIntervalSec=60
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar el servicio de Vault
sudo systemctl enable vault
sudo systemctl start vault