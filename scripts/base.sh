#!/usr/bin/env bash
set -Eeuo pipefail

echo "[BASE] Atualizando sistema..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y

echo "[BASE] Instalando utilitários..."
sudo apt install -y \
  ca-certificates curl wget gnupg lsb-release software-properties-common \
  unzip zip p7zip-full jq tree htop btop tmux rsync \
  nano vim git git-lfs openssh-client openssh-server \
  build-essential pkg-config

sudo systemctl enable --now ssh

echo "[BASE] Limpando pacotes desnecessários..."
sudo apt autoremove -y

echo "[OK] Base instalada."
