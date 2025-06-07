#!/bin/bash
# Instala Vault y lo inicia en modo de desarrollo (-dev)
sudo apt-get update
sudo apt-get install -y wget gpg unzip
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

# Inicia Vault en modo DEV, escuchando en todas las interfaces.
# Los datos se guardan en memoria y el token raíz es 'root'.
vault server -dev -dev-listen-address="0.0.0.0:8200" -dev-root-token-id="root" &