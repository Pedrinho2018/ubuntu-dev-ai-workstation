#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="Ubuntu Dev + AI Workstation"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf "\n\033[1;34m[INFO]\033[0m %s\n" "$*"; }
ok()  { printf "\033[1;32m[OK]\033[0m %s\n" "$*"; }
warn(){ printf "\033[1;33m[AVISO]\033[0m %s\n" "$*"; }
die() { printf "\033[1;31m[ERRO]\033[0m %s\n" "$*" >&2; exit 1; }

[[ "$(id -u)" -ne 0 ]] || die "Execute como usuário normal, não com sudo."

if ! command -v apt >/dev/null 2>&1; then
  die "Este projeto foi feito para Ubuntu/Kubuntu e derivados com APT."
fi

if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  log "Sistema detectado: ${PRETTY_NAME:-Linux}"
fi

echo
echo "===================================================="
echo " $PROJECT_NAME"
echo "===================================================="
echo "1) Base Linux"
echo "2) Desenvolvimento (Python/C/C++/Git)"
echo "3) IA / Machine Learning"
echo "4) DevOps"
echo "5) Redes / Segurança"
echo "6) Apps de estudo"
echo "7) NVIDIA (somente instalação física)"
echo "8) Instalar perfil completo recomendado"
echo "0) Sair"
echo "===================================================="
read -rp "Escolha: " choice

run_script() {
  local file="$1"
  [[ -f "$ROOT_DIR/scripts/$file" ]] || die "Arquivo não encontrado: $file"
  bash "$ROOT_DIR/scripts/$file"
}

case "$choice" in
  1) run_script base.sh ;;
  2) run_script dev.sh ;;
  3) run_script ai.sh ;;
  4) run_script devops.sh ;;
  5) run_script network.sh ;;
  6) run_script apps.sh ;;
  7) run_script nvidia.sh ;;
  8)
     run_script base.sh
     run_script dev.sh
     run_script ai.sh
     run_script devops.sh
     run_script network.sh
     run_script apps.sh
     ok "Perfil completo concluído."
     warn "NVIDIA não é instalada automaticamente. Rode opção 7 apenas no Ubuntu instalado fisicamente."
     ;;
  0) exit 0 ;;
  *) die "Opção inválida." ;;
esac
