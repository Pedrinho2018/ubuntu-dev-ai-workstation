#!/usr/bin/env bash
set -Eeuo pipefail

REQ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/requirements/python-ai.txt"
VENV="$HOME/.venvs/ai"

echo "[IA] Criando ambiente virtual em $VENV ..."
mkdir -p "$HOME/.venvs"
python3 -m venv "$VENV"

"$VENV/bin/python" -m pip install --upgrade pip wheel setuptools
"$VENV/bin/pip" install -r "$REQ"

echo
echo "[OK] Ambiente de IA criado."
echo "Ativar com:"
echo "  source $VENV/bin/activate"
echo
echo "Abrir Jupyter:"
echo "  jupyter lab"
echo
echo "PyTorch com GPU será configurado depois, no host físico, após validar o driver NVIDIA."
