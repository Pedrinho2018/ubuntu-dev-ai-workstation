#!/usr/bin/env bash
set -uo pipefail

PASS=0
WARN=0
FAIL=0

BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

pass() { printf "${GREEN}[OK]${RESET} %s\n" "$*"; PASS=$((PASS + 1)); }
warn() { printf "${YELLOW}[AVISO]${RESET} %s\n" "$*"; WARN=$((WARN + 1)); }
fail() { printf "${RED}[FALHA]${RESET} %s\n" "$*"; FAIL=$((FAIL + 1)); }
info() { printf "${BLUE}[INFO]${RESET} %s\n" "$*"; }

has() { command -v "$1" >/dev/null 2>&1; }

check_cmd() {
  local cmd="$1"
  local label="${2:-$1}"
  if has "$cmd"; then
    local version
    version="$($cmd --version 2>/dev/null | head -n 1 || true)"
    pass "$label instalado${version:+ — $version}"
  else
    warn "$label ainda não está instalado"
  fi
}

echo "===================================================="
echo " Ubuntu Dev + AI Workstation — Diagnóstico"
echo "===================================================="

if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  info "Sistema: ${PRETTY_NAME:-Linux}"
else
  warn "Não foi possível identificar o sistema operacional"
fi

virt="$(systemd-detect-virt 2>/dev/null || true)"
if [[ -n "$virt" && "$virt" != "none" ]]; then
  info "Virtualização detectada: $virt"
else
  info "Execução em host físico ou virtualização não detectada"
fi

cpu="$(nproc 2>/dev/null || echo '?')"
ram_mb="$(awk '/MemTotal/ {printf "%d", $2/1024}' /proc/meminfo 2>/dev/null || echo 0)"
disk_free_gb="$(df -BG / 2>/dev/null | awk 'NR==2 {gsub("G", "", $4); print $4}' || echo 0)"
info "CPU: ${cpu} thread(s)"
info "RAM: ${ram_mb} MB"
info "Espaço livre em /: ${disk_free_gb} GB"

if (( ram_mb >= 4096 )); then
  pass "Memória suficiente para o laboratório"
else
  warn "Menos de 4 GB de RAM disponível no sistema"
fi

if (( disk_free_gb >= 10 )); then
  pass "Espaço em disco adequado"
else
  warn "Menos de 10 GB livres em /"
fi

if ip route 2>/dev/null | grep -q '^default '; then
  pass "Rota padrão de rede encontrada"
else
  fail "Nenhuma rota padrão encontrada"
fi

ipv4="$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | paste -sd ', ' -)"
if [[ -n "$ipv4" ]]; then
  pass "IPv4: $ipv4"
else
  fail "Nenhum IPv4 global encontrado"
fi

if getent hosts github.com >/dev/null 2>&1; then
  pass "DNS funcionando"
else
  fail "Falha de resolução DNS"
fi

if has curl && curl -fsI --connect-timeout 7 https://github.com >/dev/null 2>&1; then
  pass "Acesso HTTPS à Internet funcionando"
elif ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
  warn "Internet responde por IP, mas o teste HTTPS falhou"
else
  fail "Sem conectividade com a Internet"
fi

echo
info "Ferramentas de desenvolvimento"
check_cmd git Git
check_cmd python3 Python
check_cmd pip3 pip
check_cmd gcc GCC
check_cmd g++ G++
check_cmd cmake CMake

echo
info "DevOps"
check_cmd docker Docker
check_cmd ansible Ansible
if has docker; then
  if systemctl is-active --quiet docker 2>/dev/null; then
    pass "Serviço Docker ativo"
  else
    warn "Docker instalado, mas o serviço não está ativo"
  fi

  if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    pass "Usuário pertence ao grupo docker"
  else
    warn "Usuário ainda não aparece no grupo docker; pode ser necessário sair e entrar novamente"
  fi
fi

echo
info "Rede e segurança"
check_cmd nmap Nmap
check_cmd tcpdump tcpdump
check_cmd tshark TShark
check_cmd openvpn OpenVPN

if systemctl list-unit-files ssh.service >/dev/null 2>&1; then
  if systemctl is-active --quiet ssh 2>/dev/null; then
    pass "SSH Server ativo"
  else
    warn "SSH Server existe, mas não está ativo"
  fi
else
  warn "SSH Server não encontrado"
fi

echo
info "Ambiente de IA"
AI_VENV="$HOME/.venvs/ai"
if [[ -x "$AI_VENV/bin/python" ]]; then
  pass "Ambiente virtual de IA encontrado em $AI_VENV"
  ai_python="$($AI_VENV/bin/python --version 2>/dev/null || true)"
  info "${ai_python:-Python do ambiente não identificado}"

  for pkg in numpy pandas sklearn jupyterlab; do
    if "$AI_VENV/bin/python" -c "import $pkg" >/dev/null 2>&1; then
      pass "Python package: $pkg"
    else
      warn "Python package ausente ou com erro: $pkg"
    fi
  done
else
  warn "Ambiente de IA ainda não foi criado"
fi

echo
echo "===================================================="
printf "Resultado: ${GREEN}%d OK${RESET} | ${YELLOW}%d avisos${RESET} | ${RED}%d falhas${RESET}\n" "$PASS" "$WARN" "$FAIL"
echo "===================================================="

if (( FAIL > 0 )); then
  exit 1
fi
exit 0
