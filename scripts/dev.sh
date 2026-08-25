#!/usr/bin/env bash
set -Eeuo pipefail

echo "[DEV] Instalando Python e toolchain C/C++..."
sudo apt update
sudo apt install -y \
  python3 python3-pip python3-venv python3-dev pipx \
  gcc g++ gdb make cmake ninja-build clang clang-format \
  default-jdk

python3 -m pipx ensurepath || true

echo "[DEV] Configurando Git..."
git config --global init.defaultBranch main

echo "[OK] Ambiente de desenvolvimento instalado."
echo "VS Code fica no módulo 'Apps de estudo'."
