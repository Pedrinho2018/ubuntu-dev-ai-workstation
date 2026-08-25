#!/usr/bin/env bash
set -Eeuo pipefail

echo "[APPS] Instalando aplicativos de trabalho e estudo..."

if command -v snap >/dev/null 2>&1; then
  sudo snap install code --classic || true
  sudo snap install dbeaver-ce || true
  sudo snap install postman || true
else
  echo "[AVISO] Snap não encontrado; VS Code, DBeaver e Postman não foram instalados automaticamente."
fi

sudo apt update
sudo apt install -y \
  libreoffice \
  flameshot \
  vlc \
  gparted \
  flatpak

if command -v code >/dev/null 2>&1; then
  echo "[APPS] Instalando extensões do VS Code..."
  extensions=(
    ms-python.python
    ms-python.vscode-pylance
    ms-vscode.cpptools
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    hashicorp.terraform
    redhat.vscode-yaml
    ms-vscode.powershell
    ms-vscode-remote.remote-ssh
    eamodio.gitlens
  )

  for ext in "${extensions[@]}"; do
    code --install-extension "$ext" --force || echo "[AVISO] Falha ao instalar extensão: $ext"
  done
fi

echo
echo "[OK] Apps principais instalados."
echo "[INFO] Inclui VS Code, DBeaver, Postman, LibreOffice, Flameshot, VLC, GParted e Flatpak."