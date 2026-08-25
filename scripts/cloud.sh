#!/usr/bin/env bash
set -Eeuo pipefail

info() { printf '[INFO] %s\n' "$*"; }
ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }

info "Instalando ferramentas base de Cloud/IaC..."
sudo apt update
sudo apt install -y ca-certificates curl wget gnupg unzip jq gh

# AWS CLI v2: o Snap é um método oficialmente suportado pela AWS.
if command -v aws >/dev/null 2>&1; then
  ok "AWS CLI já instalada: $(aws --version 2>&1 | head -n1)"
elif command -v snap >/dev/null 2>&1; then
  info "Instalando AWS CLI v2 via Snap..."
  sudo snap install aws-cli --classic || warn "Não foi possível instalar AWS CLI via Snap."
else
  warn "Snap não encontrado; AWS CLI não foi instalada automaticamente."
fi

# Terraform: só adiciona o repositório HashiCorp se houver Release para o codename atual.
if command -v terraform >/dev/null 2>&1; then
  ok "Terraform já instalado: $(terraform version | head -n1)"
else
  . /etc/os-release
  CODENAME="${UBUNTU_CODENAME:-${VERSION_CODENAME:-}}"
  if [[ -n "$CODENAME" ]] && curl -fsI "https://apt.releases.hashicorp.com/dists/${CODENAME}/Release" >/dev/null 2>&1; then
    info "Configurando repositório oficial HashiCorp para ${CODENAME}..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
    sudo apt update
    sudo apt install -y terraform
  else
    warn "HashiCorp ainda não oferece repositório APT para '${CODENAME:-desconhecido}'. Terraform foi ignorado para não quebrar o APT."
  fi
fi

# Azure CLI: Ubuntu 26.04 pode ainda não estar listado como distribuição testada pela Microsoft.
# Em vez de forçar um repositório incompatível, criamos um wrapper usando a imagem oficial do Azure CLI.
if command -v az >/dev/null 2>&1; then
  ok "Azure CLI já instalada no host."
else
  mkdir -p "$HOME/.local/bin" "$HOME/.azure"
  cat > "$HOME/.local/bin/az-container" <<'EOF'
#!/usr/bin/env bash
set -e
exec docker run --rm -it \
  -v "$HOME/.azure:/root/.azure" \
  -v "$PWD:/workspace" -w /workspace \
  mcr.microsoft.com/azure-cli "$@"
EOF
  chmod +x "$HOME/.local/bin/az-container"
  warn "Azure CLI nativa não foi forçada. Use 'az-container' após o Docker estar instalado."
fi

# Garante ~/.local/bin no PATH para shells novos.
if ! grep -qs 'HOME/.local/bin' "$HOME/.profile" 2>/dev/null; then
  printf '\n# Ubuntu Dev + AI Workstation\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.profile"
fi

echo
ok "Módulo Cloud/IaC concluído."
echo "Ferramentas previstas: AWS CLI, GitHub CLI, Terraform (quando suportado) e Azure CLI via container."