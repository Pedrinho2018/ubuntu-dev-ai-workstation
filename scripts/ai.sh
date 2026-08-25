#!/usr/bin/env bash
set -Eeuo pipefail

REQ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/requirements/python-ai.txt"
VENV="$HOME/.venvs/ai"
PYTORCH_INDEX_URL="${PYTORCH_INDEX_URL:-https://download.pytorch.org/whl/cu128}"

echo "[IA] Preparando ambiente virtual em $VENV ..."
mkdir -p "$HOME/.venvs"

if [[ ! -x "$VENV/bin/python" ]]; then
  python3 -m venv "$VENV"
fi

"$VENV/bin/python" -m pip install --upgrade pip wheel setuptools
"$VENV/bin/pip" install -r "$REQ"

echo
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  echo "[IA/GPU] NVIDIA ativa. Instalando PyTorch com suporte CUDA..."
  "$VENV/bin/python" -m pip install --upgrade torch torchvision torchaudio --index-url "$PYTORCH_INDEX_URL"

  echo "[IA/GPU] Validando PyTorch + CUDA..."
  "$VENV/bin/python" - <<'PY'
import torch

print(f"[OK] PyTorch: {torch.__version__}")
print(f"[OK] CUDA disponível: {torch.cuda.is_available()}")
print(f"[INFO] CUDA do PyTorch: {torch.version.cuda}")

if torch.cuda.is_available():
    print(f"[OK] GPU IA: {torch.cuda.get_device_name(0)}")
else:
    print("[AVISO] PyTorch instalado, mas CUDA não está disponível.")
PY
else
  echo "[AVISO] Driver NVIDIA ativo não foi detectado."
  echo "[INFO] PyTorch CUDA não será instalado automaticamente agora."
  echo "[INFO] Após instalar/validar o driver NVIDIA, execute novamente o módulo de IA."
fi

echo
echo "[OK] Ambiente de IA preparado."
echo "Ativar com:"
echo "  source $VENV/bin/activate"
echo
echo "Abrir Jupyter:"
echo "  jupyter lab"
