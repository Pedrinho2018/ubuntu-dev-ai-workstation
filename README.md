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

## Teste recomendado primeiro

Antes de instalar no computador físico, valide tudo em uma VM Hyper-V com Ubuntu 26.04 LTS.

Guia completo:

- [`docs/hyper-v-ubuntu-26.04.md`](docs/hyper-v-ubuntu-26.04.md)

Perfil de instalação automatizada para VM:

- [`autoinstall/autoinstall-vm.yaml`](autoinstall/autoinstall-vm.yaml)

URL RAW para importar diretamente no instalador do Ubuntu:

```text
https://raw.githubusercontent.com/Pedrinho2018/ubuntu-dev-ai-workstation/main/autoinstall/autoinstall-vm.yaml
```

> O perfil de VM usa o disco inteiro apresentado ao instalador. Não use em máquina física sem revisar `storage`.

## Uso depois da instalação

```bash
git clone https://github.com/Pedrinho2018/ubuntu-dev-ai-workstation.git
cd ubuntu-dev-ai-workstation
chmod +x setup.sh scripts/*.sh
./setup.sh
```

## Setup v0.2

O `setup.sh` agora possui:

- menu contínuo: você pode instalar vários módulos sem reabrir o script
- diagnóstico do ambiente
- detecção de virtualização
- teste de DNS e acesso HTTPS
- logs automáticos de cada execução
- tratamento de erros com indicação da linha e arquivo de log
- execução não interativa por argumentos

Os logs ficam em:

```text
~/.local/state/ubuntu-dev-ai-workstation/logs/
```

### Comandos rápidos

Abrir o menu:

```bash
./setup.sh
```

Instalar o perfil completo:

```bash
./setup.sh --full
```

Executar somente o diagnóstico:

```bash
./setup.sh --check
```

Ver versão:

```bash
./setup.sh --version
```

## Módulos

O menu do `setup.sh` permite instalar:

1. Base Linux
2. Desenvolvimento
3. IA / Machine Learning
4. DevOps
5. Redes / Segurança
6. Apps de estudo
7. NVIDIA no host físico
8. Perfil completo recomendado
9. Diagnóstico / validar ambiente

> Não instale o módulo NVIDIA dentro da VM. O próprio script tenta detectar virtualização e bloqueia essa etapa.

## Diagnóstico

O arquivo [`scripts/verify.sh`](scripts/verify.sh) verifica:

- sistema operacional e virtualização
- CPU, RAM e espaço livre
- rota padrão e endereço IPv4
- DNS
- acesso HTTPS à Internet
- Git, Python, pip, GCC, G++, CMake
- Docker e Ansible
- Nmap, tcpdump, TShark e OpenVPN
- status do SSH Server
- ambiente virtual de IA e bibliotecas principais

Ao final ele mostra um resumo com quantidade de testes OK, avisos e falhas.

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
- kubectl / ambiente Kubernetes local
- extensões recomendadas do VS Code
- configuração opcional KDE Plasma
