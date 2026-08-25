#!/usr/bin/env bash
set -Eeuo pipefail

echo "[APPS] Instalando apps..."

if command -v snap >/dev/null 2>&1; then
  sudo snap install code --classic || true
else
  echo "[AVISO] Snap não encontrado; VS Code não foi instalado automaticamente."
fi

sudo apt update
sudo apt install -y \
  libreoffice \
  flameshot \
  vlc \
  gparted \
  flatpak

echo
echo "[OK] Apps básicos instalados."
echo "[INFO] Steam e Ollama serão adicionados depois do teste da VM."
