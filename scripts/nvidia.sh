#!/usr/bin/env bash
set -Eeuo pipefail

virt="$(systemd-detect-virt 2>/dev/null || true)"

if [[ -n "$virt" && "$virt" != "none" ]]; then
  echo "[AVISO] Virtualização detectada: $virt"
  echo "Não vou instalar driver NVIDIA dentro da VM."
  exit 0
fi

if ! lspci | grep -qi nvidia; then
  echo "[AVISO] Nenhuma GPU NVIDIA detectada."
  exit 0
fi

echo "[NVIDIA] Instalando ubuntu-drivers..."
sudo apt update
sudo apt install -y ubuntu-drivers-common

echo "[NVIDIA] Drivers recomendados:"
ubuntu-drivers devices || true

echo
read -rp "Instalar automaticamente o driver recomendado? [s/N]: " ans
if [[ "${ans,,}" == "s" ]]; then
  sudo ubuntu-drivers install
  echo "[OK] Driver instalado. Reinicie o computador."
else
  echo "[INFO] Instalação cancelada."
fi
