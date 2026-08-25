#!/usr/bin/env bash
set -Eeuo pipefail

echo "[DEVOPS] Instalando ferramentas..."
sudo apt update
sudo apt install -y \
  docker.io docker-compose-v2 \
  podman buildah skopeo \
  ansible \
  shellcheck \
  make jq

sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

echo
echo "[OK] Docker, Compose, Podman, Buildah, Skopeo e Ansible instalados."
echo "[AVISO] Para usar Docker sem sudo, encerre a sessão e entre novamente."
echo "[INFO] Terraform/OpenTofu ficará para o próximo módulo para usarmos o repositório oficial."
