# Ubuntu Dev + AI Workstation

Automação modular para preparar uma estação Ubuntu/Kubuntu voltada para estudo, desenvolvimento, IA, DevOps, redes e segurança.

## Objetivo

Montar um ambiente reutilizável para:

- Faculdade e programação
- Python, C e C++
- IA / Machine Learning
- Docker / Podman / Ansible
- Redes e segurança
- Administração remota via SSH/RDP
- NVIDIA no host físico

## Uso

```bash
git clone https://github.com/Pedrinho2018/ubuntu-dev-ai-workstation.git
cd ubuntu-dev-ai-workstation
chmod +x setup.sh scripts/*.sh
./setup.sh
```

## Primeiro teste na VM

Na VM, execute primeiro:

1. Base Linux
2. Desenvolvimento
3. IA
4. DevOps
5. Redes
6. Apps

> Não instale o módulo NVIDIA dentro da VM. O script tenta detectar virtualização e bloqueia essa etapa.

## IA

O ambiente Python é criado em:

```bash
~/.venvs/ai
```

Ative com:

```bash
source ~/.venvs/ai/bin/activate
```

Depois:

```bash
jupyter lab
```

## Segurança

Nunca publique:

- senhas
- tokens
- chaves SSH privadas
- arquivos `.ovpn`
- certificados privados
- credenciais de cloud

O `.gitignore` bloqueia vários formatos sensíveis.

## Próximos módulos

- Terraform/OpenTofu via repositório oficial
- Ollama
- PyTorch + CUDA para NVIDIA
- Steam
- AWS CLI / Azure CLI
- configuração opcional KDE Plasma
- `autoinstall.yaml`
