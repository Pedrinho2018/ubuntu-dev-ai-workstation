#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="Ubuntu Dev + AI Workstation"
VERSION="0.2.0"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ubuntu-dev-ai-workstation"
LOG_DIR="$STATE_DIR/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/setup-$(date +%Y%m%d-%H%M%S).log"

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

log()  { printf "\n${BLUE}[INFO]${RESET} %s\n" "$*"; }
ok()   { printf "${GREEN}[OK]${RESET} %s\n" "$*"; }
warn() { printf "${YELLOW}[AVISO]${RESET} %s\n" "$*"; }
die()  { printf "${RED}[ERRO]${RESET} %s\n" "$*" >&2; exit 1; }

on_error() {
  local exit_code=$?
  local line_no="${BASH_LINENO[0]:-?}"
  printf "\n${RED}[ERRO]${RESET} Falha na linha %s (código %s).\n" "$line_no" "$exit_code" >&2
  printf "${YELLOW}[LOG]${RESET} Consulte: %s\n" "$LOG_FILE" >&2
  exit "$exit_code"
}
trap on_error ERR

# Tudo que aparecer no terminal também fica registrado em log.
exec > >(tee -a "$LOG_FILE") 2>&1

usage() {
  cat <<EOF
$PROJECT_NAME v$VERSION

Uso:
  ./setup.sh              Abre o menu interativo
  ./setup.sh --full       Instala o perfil completo e valida o ambiente
  ./setup.sh --check      Executa apenas o diagnóstico
  ./setup.sh --version    Mostra a versão
  ./setup.sh --help       Mostra esta ajuda
EOF
}

preflight() {
  [[ "$(id -u)" -ne 0 ]] || die "Execute como usuário normal, não com sudo."
  command -v apt >/dev/null 2>&1 || die "Este projeto requer Ubuntu/Kubuntu ou derivado com APT."

  if [[ -r /etc/os-release ]]; then
    . /etc/os-release
    log "Sistema detectado: ${PRETTY_NAME:-Linux}"
  fi

  local virt
  virt="$(systemd-detect-virt 2>/dev/null || true)"
  if [[ -n "$virt" && "$virt" != "none" ]]; then
    log "Virtualização detectada: $virt"
  else
    log "Execução em host físico ou virtualização não detectada"
  fi

  if getent hosts github.com >/dev/null 2>&1; then
    ok "DNS funcionando"
  else
    warn "DNS não respondeu para github.com. Instalações podem falhar."
  fi

  if command -v curl >/dev/null 2>&1 && curl -fsI --connect-timeout 7 https://github.com >/dev/null 2>&1; then
    ok "Acesso HTTPS à Internet funcionando"
  else
    warn "Não foi possível validar acesso HTTPS ao GitHub."
  fi

  log "Log desta execução: $LOG_FILE"
}

run_script() {
  local file="$1"
  local path="$ROOT_DIR/scripts/$file"

  [[ -f "$path" ]] || die "Arquivo não encontrado: scripts/$file"

  log "Executando módulo: $file"
  bash "$path"
  ok "Módulo concluído: $file"
}

run_full() {
  local mode="${1:-interactive}"

  log "Iniciando perfil completo recomendado"
  run_script base.sh
  run_script dev.sh
  run_script ai.sh
  run_script devops.sh
  run_script network.sh
  run_script apps.sh

  ok "Perfil completo concluído."
  warn "NVIDIA não é instalada automaticamente. Use a opção 7 somente no Ubuntu instalado fisicamente."

  if [[ "$mode" == "automatic" ]]; then
    run_script verify.sh
    return
  fi

  echo
  read -rp "Executar diagnóstico final agora? [S/n]: " answer
  if [[ -z "$answer" || "${answer,,}" == "s" ]]; then
    run_script verify.sh
  fi
}

show_menu() {
  while true; do
    echo
    echo "===================================================="
    echo " $PROJECT_NAME v$VERSION"
    echo "===================================================="
    echo "1) Base Linux"
    echo "2) Desenvolvimento (Python/C/C++/Git)"
    echo "3) IA / Machine Learning"
    echo "4) DevOps"
    echo "5) Redes / Segurança"
    echo "6) Apps de estudo"
    echo "7) NVIDIA (somente instalação física)"
    echo "8) Instalar perfil completo recomendado"
    echo "9) Diagnóstico / validar ambiente"
    echo "0) Sair"
    echo "===================================================="
    read -rp "Escolha: " choice

    case "$choice" in
      1) run_script base.sh ;;
      2) run_script dev.sh ;;
      3) run_script ai.sh ;;
      4) run_script devops.sh ;;
      5) run_script network.sh ;;
      6) run_script apps.sh ;;
      7) run_script nvidia.sh ;;
      8) run_full interactive ;;
      9) run_script verify.sh || true ;;
      0)
        ok "Saindo. Log salvo em: $LOG_FILE"
        exit 0
        ;;
      *) warn "Opção inválida." ;;
    esac
  done
}

main() {
  case "${1:-}" in
    --help|-h)
      usage
      exit 0
      ;;
    --version|-v)
      echo "$PROJECT_NAME v$VERSION"
      exit 0
      ;;
    --full)
      preflight
      run_full automatic
      ;;
    --check)
      preflight
      run_script verify.sh
      ;;
    "")
      preflight
      show_menu
      ;;
    *)
      usage
      die "Argumento desconhecido: $1"
      ;;
  esac
}

main "$@"
