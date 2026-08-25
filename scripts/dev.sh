#!/usr/bin/env bash
set -Eeuo pipefail

echo "[DEV] Instalando ambiente de desenvolvimento..."
sudo apt update
sudo apt install -y \
  python3 python3-pip python3-venv python3-dev pipx \
  gcc g++ gdb make cmake ninja-build clang clang-format \
  default-jdk \
  nodejs npm \
  sqlite3 postgresql-client default-mysql-client \
  shellcheck

python3 -m pipx ensurepath || true

echo "[DEV] Configurando Git..."
git config --global init.defaultBranch main

echo
echo "[OK] Ambiente de desenvolvimento instalado."
echo "[INFO] Linguagens: Python, C/C++, Java e JavaScript/Node.js."
echo "[INFO] Bancos: SQLite, PostgreSQL client e MySQL/MariaDB client."
echo "[INFO] VS Code e extensões ficam no módulo de Apps."