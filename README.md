# Ubuntu DevSecOps + AI Workstation

Automação modular para preparar um Ubuntu voltado ao uso real em desenvolvimento, DevOps, cloud, redes, segurança, administração remota de infraestrutura Windows e estudos de Machine Learning.

## Perfil principal

O projeto agora foi ajustado para um uso misto de:

- Python, C/C++, Java e JavaScript/Node.js
- PostgreSQL, MySQL/MariaDB e SQLite
- Machine Learning e análise de dados financeiros
- Docker, Docker Compose, Podman, Buildah e Ansible
- AWS CLI, Azure CLI, Terraform e GitHub CLI
- Kubernetes com kubectl e Helm
- Wireshark, Nmap, tcpdump, TShark, OpenVPN e ferramentas de rede
- PowerShell 7, Remmina/RDP, SMB, LDAP e SSH para infraestrutura Windows
- VS Code com extensões de Python, C++, Docker, Kubernetes, Terraform, YAML, PowerShell e Remote SSH
- NVIDIA no host físico, em módulo separado

## Instalação física

Para formatar uma máquina real, **não use o `autoinstall-vm.yaml`**.

O perfil de Autoinstall existente foi criado para laboratório/Hyper-V e usa o disco inteiro apresentado ao instalador.

Guia seguro para instalação física:

- [`docs/physical-install.md`](docs/physical-install.md)

## Laboratório Hyper-V

Guia da VM:

- [`docs/hyper-v-ubuntu-26.04.md`](docs/hyper-v-ubuntu-26.04.md)

Autoinstall exclusivo para VM:

- [`autoinstall/autoinstall-vm.yaml`](autoinstall/autoinstall-vm.yaml)

URL RAW:

```text
https://raw.githubusercontent.com/Pedrinho2018/ubuntu-dev-ai-workstation/main/autoinstall/autoinstall-vm.yaml
```

## Pós-instalação

```bash
sudo apt update
sudo apt install -y git

git clone https://github.com/Pedrinho2018/ubuntu-dev-ai-workstation.git
cd ubuntu-dev-ai-workstation
chmod +x setup.sh scripts/*.sh
./setup.sh
```

## Setup v0.3

O menu atual possui:

```text
1)  Base Linux
2)  Desenvolvimento (Python/C++/Java/JS/Bancos)
3)  IA / Machine Learning / Dados financeiros
4)  DevOps / Containers (Docker/Podman/Ansible)
5)  Cloud / IaC (AWS/Azure/Terraform/GitHub CLI)
6)  Kubernetes (kubectl/Helm)
7)  Redes / Segurança
8)  Administração remota Windows/Infra
9)  Apps + VS Code + extensões
10) NVIDIA (somente host físico)
11) Instalar MEU PERFIL PRINCIPAL
12) Diagnóstico / validar ambiente
0)  Sair
```

### Perfil principal

Para instalar os módulos principais automaticamente:

```bash
./setup.sh --full
```

Ou abra o menu e escolha a opção 11.

O driver NVIDIA continua separado por segurança.

## Diagnóstico

```bash
./setup.sh --check
```

O diagnóstico verifica:

- sistema e virtualização
- CPU, RAM e disco
- IPv4, rota, DNS e Internet
- Git, Python, C/C++, Java e Node.js
- clientes PostgreSQL e MySQL
- Docker, Podman e Ansible
- AWS CLI, GitHub CLI, Terraform e Azure CLI/container
- kubectl e Helm
- Nmap, tcpdump, TShark, OpenVPN e openfortivpn
- SMB, LDAP, PowerShell e SSH
- ambiente de Machine Learning
- presença/estado do driver NVIDIA

Logs:

```text
~/.local/state/ubuntu-dev-ai-workstation/logs/
```

## Machine Learning

O ambiente é criado em:

```bash
~/.venvs/ai
```

Bibliotecas principais:

- NumPy
- Pandas
- SciPy
- Matplotlib / Plotly
- scikit-learn
- Statsmodels
- yfinance
- XGBoost
- Optuna
- JupyterLab

Ativar:

```bash
source ~/.venvs/ai/bin/activate
jupyter lab
```

## Cloud

O módulo Cloud usa métodos conservadores para não quebrar uma versão nova do Ubuntu:

- AWS CLI via Snap oficial suportado pela AWS
- GitHub CLI via APT
- Terraform somente quando o repositório HashiCorp possui suporte ao codename atual
- Azure CLI nativa não é forçada em versões de Ubuntu ainda não listadas pela Microsoft; nesses casos é criado o comando `az-container`, usando a imagem oficial do Azure CLI via Docker

## Administração Windows

O Ubuntu pode administrar vários serviços remotamente, mas não substitui completamente uma estação Windows de administração.

O projeto instala:

- Remmina/RDP
- PowerShell 7
- SSH
- SMB/CIFS
- LDAP tools
- openfortivpn

Ferramentas como **RSAT, ADUC e GPMC continuam sendo Windows-only**. Para essas tarefas, use RDP para uma estação/servidor Windows autorizado.

## Segurança

Nunca publique no repositório:

- senhas
- tokens
- chaves SSH privadas
- arquivos VPN com credenciais
- certificados privados
- credenciais AWS/Azure

O projeto não configura automaticamente credenciais de cloud.

## Próximos passos

- PyTorch + CUDA após validar NVIDIA no host físico
- Ollama opcional para modelos locais pequenos
- ambiente Kubernetes local com kind
- OpenTofu opcional
- hardening básico do workstation
