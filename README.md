# Ubuntu DevSecOps + AI Workstation

Automação modular para preparar um Ubuntu voltado ao uso real em desenvolvimento, DevOps, cloud, redes, segurança, administração remota de infraestrutura Windows e estudos de Machine Learning.

## Perfil principal

O projeto está ajustado para um uso misto de:

- Python, C/C++, Java e JavaScript/Node.js
- PostgreSQL, MySQL/MariaDB e SQLite
- Machine Learning e análise de dados financeiros
- PyTorch com CUDA quando uma GPU NVIDIA ativa é detectada
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

## Setup v0.4

A versão 0.4 adiciona instalação e validação de **PyTorch + CUDA** no ambiente de IA.

Quando `nvidia-smi` está ativo, o módulo de IA:

1. prepara o ambiente virtual `~/.venvs/ai`;
2. instala as bibliotecas de Machine Learning;
3. instala `torch`, `torchvision` e `torchaudio` com build CUDA;
4. executa `torch.cuda.is_available()`;
5. mostra a versão do PyTorch, versão CUDA e nome da GPU detectada.

O diagnóstico também passa a validar automaticamente PyTorch e CUDA.

O menu atual possui:

```text
1)  Base Linux
2)  Desenvolvimento (Python/C++/Java/JS/Bancos)
3)  IA / Machine Learning / PyTorch CUDA
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
- PyTorch
- disponibilidade de CUDA no PyTorch
- GPU usada pelo PyTorch
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
- PyTorch / torchvision / torchaudio em hosts NVIDIA compatíveis

Ativar:

```bash
source ~/.venvs/ai/bin/activate
jupyter lab
```

### Testar PyTorch + CUDA

```bash
source ~/.venvs/ai/bin/activate
python -c "import torch; print('PyTorch:', torch.__version__); print('CUDA:', torch.cuda.is_available()); print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'Não disponível')"
```

## Cloud

O módulo Cloud usa métodos conservadores para não quebrar uma versão nova do Ubuntu:

- AWS CLI via método configurado no projeto
- GitHub CLI
- Terraform quando disponível para o Ubuntu utilizado
- Azure CLI nativa não é forçada quando não está disponível; nesses casos o projeto pode usar uma alternativa em container

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

- Ollama opcional para modelos locais pequenos
- ambiente Kubernetes local com kind
- OpenTofu opcional
- hardening básico do workstation
- testes funcionais automatizados de Docker, Terraform, SSH e Jupyter
