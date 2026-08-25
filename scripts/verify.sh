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
echo " Ubuntu DevSecOps + AI Workstation — Diagnóstico"
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

(( ram_mb >= 4096 )) && pass "Memória suficiente para o laboratório" || warn "Menos de 4 GB de RAM disponível"
(( disk_free_gb >= 10 )) && pass "Espaço em disco adequado" || warn "Menos de 10 GB livres em /"

if ip route 2>/dev/null | grep -q '^default '; then pass "Rota padrão encontrada"; else fail "Nenhuma rota padrão encontrada"; fi
ipv4="$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | paste -sd ', ' -)"
[[ -n "$ipv4" ]] && pass "IPv4: $ipv4" || fail "Nenhum IPv4 global encontrado"
getent hosts github.com >/dev/null 2>&1 && pass "DNS funcionando" || fail "Falha de resolução DNS"

if has curl && curl -fsI --connect-timeout 7 https://github.com >/dev/null 2>&1; then
  pass "Acesso HTTPS à Internet funcionando"
elif ping -c 1 -W 3 1.1.1.1 >/dev/null 2>&1; then
  warn "Internet responde por IP, mas HTTPS falhou"
else
  fail "Sem conectividade com a Internet"
fi

echo
info "Desenvolvimento"
check_cmd git Git
check_cmd python3 Python
check_cmd pip3 pip
check_cmd gcc GCC
check_cmd g++ G++
check_cmd cmake CMake
check_cmd node Node.js
check_cmd npm npm
check_cmd java Java
check_cmd psql PostgreSQL-client
check_cmd mysql MySQL-client

echo
info "DevOps / Containers"
check_cmd docker Docker
check_cmd podman Podman
check_cmd ansible Ansible
if has docker; then
  systemctl is-active --quiet docker 2>/dev/null && pass "Serviço Docker ativo" || warn "Docker instalado, mas serviço inativo"
  id -nG "$USER" | tr ' ' '\n' | grep -qx docker && pass "Usuário pertence ao grupo docker" || warn "Grupo docker ainda não aplicado à sessão"
fi

echo
info "Cloud / IaC"
check_cmd aws AWS-CLI
check_cmd gh GitHub-CLI
check_cmd terraform Terraform
if has az; then
  pass "Azure CLI nativa instalada"
elif has az-container; then
  pass "Azure CLI disponível via az-container"
else
  warn "Azure CLI ainda não está disponível"
fi

echo
info "Kubernetes"
check_cmd kubectl kubectl
check_cmd helm Helm

echo
info "Redes / Segurança / Infra"
check_cmd nmap Nmap
check_cmd tcpdump tcpdump
check_cmd tshark TShark
check_cmd openvpn OpenVPN
check_cmd openfortivpn openfortivpn
check_cmd smbclient smbclient
check_cmd ldapsearch ldap-utils
check_cmd pwsh PowerShell

if systemctl list-unit-files ssh.service >/dev/null 2>&1; then
  systemctl is-active --quiet ssh 2>/dev/null && pass "SSH Server ativo" || warn "SSH Server existe, mas não está ativo"
else
  warn "SSH Server não encontrado"
fi

echo
info "Ambiente de IA / Machine Learning"
AI_VENV="$HOME/.venvs/ai"
if [[ -x "$AI_VENV/bin/python" ]]; then
  pass "Ambiente virtual de IA encontrado em $AI_VENV"
  for pkg in numpy pandas sklearn jupyterlab statsmodels yfinance xgboost optuna; do
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
info "GPU"
if has nvidia-smi; then
  pass "NVIDIA driver ativo"
  nvidia-smi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>/dev/null || true
elif lspci 2>/dev/null | grep -qi nvidia; then
  warn "GPU NVIDIA detectada, mas nvidia-smi não está disponível"
else
  info "Nenhuma GPU NVIDIA detectada neste ambiente"
fi

echo
echo "===================================================="
printf "Resultado: ${GREEN}%d OK${RESET} | ${YELLOW}%d avisos${RESET} | ${RED}%d falhas${RESET}\n" "$PASS" "$WARN" "$FAIL"
echo "===================================================="

(( FAIL > 0 )) && exit 1
exit 0
