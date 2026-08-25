#!/usr/bin/env bash
set -Eeuo pipefail

info() { printf '[INFO] %s\n' "$*"; }
ok()   { printf '[OK] %s\n' "$*"; }
warn() { printf '[AVISO] %s\n' "$*"; }

sudo apt update
sudo apt install -y curl ca-certificates

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) KARCH="amd64" ;;
  aarch64|arm64) KARCH="arm64" ;;
  *)
    warn "Arquitetura não suportada automaticamente para kubectl: $ARCH"
    exit 0
    ;;
esac

if command -v kubectl >/dev/null 2>&1; then
  ok "kubectl já instalado: $(kubectl version --client 2>/dev/null | head -n1)"
else
  info "Instalando kubectl pelo binário oficial e validando SHA256..."
  TMP_DIR="$(mktemp -d)"
  trap 'rm -rf "$TMP_DIR"' EXIT
  KVER="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
  curl -fsSL "https://dl.k8s.io/release/${KVER}/bin/linux/${KARCH}/kubectl" -o "$TMP_DIR/kubectl"
  curl -fsSL "https://dl.k8s.io/release/${KVER}/bin/linux/${KARCH}/kubectl.sha256" -o "$TMP_DIR/kubectl.sha256"
  printf '%s  %s\n' "$(cat "$TMP_DIR/kubectl.sha256")" "$TMP_DIR/kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 "$TMP_DIR/kubectl" /usr/local/bin/kubectl
  ok "kubectl instalado: $KVER"
fi

if command -v helm >/dev/null 2>&1; then
  ok "Helm já instalado: $(helm version --short 2>/dev/null || true)"
elif command -v snap >/dev/null 2>&1; then
  info "Instalando Helm via Snap..."
  sudo snap install helm --classic || warn "Falha ao instalar Helm via Snap."
else
  warn "Snap não encontrado; Helm não foi instalado automaticamente."
fi

echo
ok "Módulo Kubernetes concluído."
echo "Use Docker/Podman para os containers e kubectl/Helm para seus laboratórios Kubernetes."