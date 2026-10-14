#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV="${AI_AGENTS_VENV:-$HOME/.venvs/agents}"
COMPOSE_FILE="$ROOT_DIR/compose/agents.compose.yaml"
ENV_FILE="$ROOT_DIR/compose/.env.agents"
MODEL="${OLLAMA_MODEL:-qwen3:4b}"

info() { printf '[AGENTS] %s\n' "$*"; }
fail() { printf '[ERRO] %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'USAGE'
Agentes locais - Ubuntu DevSecOps + AI Workstation

  ./scripts/agents.sh install           Instala LangGraph no venv isolado
  ./scripts/agents.sh install-ollama    Baixa e confirma o instalador oficial
  ./scripts/agents.sh model-pull        Baixa modelo Ollama (OLLAMA_MODEL)
  ./scripts/agents.sh up                Inicia n8n somente em localhost
  ./scripts/agents.sh down              Para n8n sem apagar os dados
  ./scripts/agents.sh status            Diagnostico sem modificar o sistema
  ./scripts/agents.sh chat TEXTO...     Chat local com historico SQLite

Variaveis: AI_AGENTS_VENV, OLLAMA_MODEL (padrao qwen3:4b).
USAGE
}

require_user() { [[ "$(id -u)" -ne 0 ]] || fail 'Execute como usuario normal, sem sudo.'; }
require_cmd() { command -v "$1" >/dev/null 2>&1 || fail "Comando ausente: $1"; }

install_python() {
  require_cmd python3
  if [[ ! -x "$VENV/bin/python" ]]; then
    mkdir -p "$(dirname "$VENV")"
    python3 -m venv "$VENV" || fail 'Falha criando ambiente. Instale python3-venv.'
  fi
  "$VENV/bin/python" -m pip install -r "$ROOT_DIR/requirements/python-agents.txt"
  info "LangGraph pronto em $VENV"
}

install_ollama() {
  if command -v ollama >/dev/null 2>&1; then
    info "Ollama instalado: $(ollama --version 2>&1 | head -n1)"
    return
  fi
  require_cmd curl
  local tmp answer
  tmp="$(mktemp)"
  if ! curl --proto '=https' --tlsv1.2 -fsSL https://ollama.com/install.sh -o "$tmp"; then
    rm -f "$tmp"
    fail 'Nao foi possivel obter o instalador oficial.'
  fi
  info 'Instalador oficial baixado de https://ollama.com/install.sh.'
  info 'Pode solicitar sudo e configurar servico systemd.'
  printf 'Executar instalador do Ollama? [s/N] '
  read -r answer || true
  if [[ "${answer,,}" == "s" ]]; then
    sh "$tmp"
  else
    info 'Instalacao cancelada.'
  fi
  rm -f "$tmp"
}

make_env() {
  if [[ -f "$ENV_FILE" ]]; then return; fi
  require_cmd python3
  local key
  key="$(python3 -c 'import secrets; print(secrets.token_hex(32))')"
  (umask 077; printf 'N8N_ENCRYPTION_KEY=%s\nN8N_IMAGE=n8nio/n8n:latest\n' "$key" > "$ENV_FILE")
  info 'Chave privada criada em compose/.env.agents; mantenha backup seguro.'
}

compose() {
  require_cmd docker
  docker compose version >/dev/null 2>&1 || fail 'Docker Compose v2 nao encontrado.'
  docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" "$@"
}

status() {
  if [[ -x "$VENV/bin/python" ]] && "$VENV/bin/python" -c 'import langgraph, langchain_ollama' >/dev/null 2>&1; then
    info 'LangGraph: OK'
  else
    info 'LangGraph: nao instalado'
  fi
  if command -v ollama >/dev/null 2>&1; then
    info "Ollama: $(ollama --version 2>&1 | head -n1)"
    if command -v curl >/dev/null 2>&1 && curl -fsS --max-time 3 http://127.0.0.1:11434/api/tags >/dev/null; then
      info 'API Ollama local: OK'
    else
      info 'API Ollama local: indisponivel'
    fi
  else
    info 'Ollama: nao instalado'
  fi
  if [[ -f "$ENV_FILE" ]] && command -v docker >/dev/null 2>&1; then
    compose ps || info 'n8n: sem acesso ao Docker'
  else
    info 'n8n: nao configurado'
  fi
}

main() {
  case "${1:-help}" in
    help|--help|-h) usage; return ;;
  esac
  require_user
  case "${1:-help}" in
    install) install_python ;;
    install-ollama) install_ollama ;;
    model-pull) require_cmd ollama; ollama pull "$MODEL" ;;
    up)
      make_env
      compose up -d
      info 'n8n em http://127.0.0.1:5678; crie seu usuario no primeiro acesso.'
      ;;
    down)
      [[ -f "$ENV_FILE" ]] || fail 'n8n ainda nao configurado.'
      compose down
      ;;
    status) status ;;
    chat)
      shift
      [[ -x "$VENV/bin/python" ]] || fail 'Primeiro execute: agents.sh install'
      (($# > 0)) || fail 'Informe um texto para conversar.'
      OLLAMA_MODEL="$MODEL" "$VENV/bin/python" "$ROOT_DIR/examples/agent_chat.py" "$*"
      ;;
    *) usage; fail "Comando desconhecido: $1" ;;
  esac
}

main "$@"
