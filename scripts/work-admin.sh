#!/usr/bin/env bash
set -Eeuo pipefail

info() { printf '[INFO] %s\n' "$*"; }
ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }

info "Instalando ferramentas para administração remota de infraestrutura Windows..."
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt install -y \
  remmina remmina-plugin-rdp remmina-plugin-vnc \
  smbclient cifs-utils ldap-utils \
  openssh-client openssh-server \
  openfortivpn \
  dnsutils whois

sudo systemctl enable --now ssh

if command -v pwsh >/dev/null 2>&1; then
  ok "PowerShell já instalado: $(pwsh --version 2>/dev/null || true)"
elif command -v snap >/dev/null 2>&1; then
  info "Instalando PowerShell 7 via Snap..."
  sudo snap install powershell --classic || warn "Não foi possível instalar PowerShell via Snap."
else
  warn "Snap não encontrado; PowerShell não foi instalado automaticamente."
fi

echo
ok "Ferramentas de administração remota instaladas."
echo "- Remmina: RDP/VNC para servidores e estações Windows"
echo "- smbclient/cifs-utils: compartilhamentos SMB"
echo "- ldap-utils: consultas LDAP"
echo "- SSH: administração remota"
echo "- openfortivpn: cliente comunitário para FortiGate SSL VPN"
echo "- PowerShell 7: automação multiplataforma"
echo
warn "RSAT, ADUC e GPMC continuam sendo ferramentas Windows. Para essas tarefas, use RDP em uma estação/servidor Windows autorizado."
warn "openfortivpn pode não atender ambientes Fortinet com MFA/SAML ou políticas específicas; use FortiClient oficial quando exigido pela organização."