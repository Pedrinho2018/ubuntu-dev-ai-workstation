# Ubuntu 26.04 no Hyper-V — passo a passo

Guia de laboratório para testar o Ubuntu 26.04 LTS Desktop em uma VM do Hyper-V antes de instalar em máquina física.

## Configuração recomendada da VM

- Nome: `Ubuntu-26.04-Lab`
- Geração: `2`
- Memória: `6144 MB`
- Memória dinâmica: habilitada
- Processadores virtuais: `4`
- Disco: `60 GB` VHDX
- Rede: `Default Switch`
- ISO: `ubuntu-26.04-desktop-amd64.iso`

## Secure Boot

Em **Configurações > Segurança**:

- Habilitar Inicialização Segura: marcado
- Modelo: `Microsoft UEFI Certificate Authority`

Não use o modelo `Microsoft Windows` para inicializar a ISO do Ubuntu.

Se aparecer o erro:

```text
The signed image's hash is not allowed (DB)
```

Desligue a VM completamente e troque o modelo para `Microsoft UEFI Certificate Authority`.

## Instalação automatizada

No instalador:

1. Escolha **Instalar Ubuntu**.
2. Escolha **Automatizado com arquivo de instalação automática**.
3. No campo de URL, use o arquivo RAW:

```text
https://raw.githubusercontent.com/Pedrinho2018/ubuntu-dev-ai-workstation/main/autoinstall/autoinstall-vm.yaml
```

Não use a URL com `/blob/`, pois ela aponta para uma página HTML do GitHub e o instalador retornará `Arquivo de instalação automática inválido`.

## Colar texto no Hyper-V

Durante o instalador, `Ctrl+V` pode não funcionar na sessão básica.

No console do Hyper-V:

1. Copie o texto no Windows.
2. Clique no campo dentro da VM.
3. Use **Área de Transferência > Digitar texto da Área de Transferência**.

## O que o autoinstall-vm.yaml faz

O perfil de VM configura:

- idioma `pt_BR.UTF-8`
- teclado brasileiro
- timezone `America/Cuiaba`
- Ubuntu Desktop completo
- SSH
- Git
- curl/wget
- Python 3 + pip + venv
- build-essential
- atualizações de segurança

A criação do usuário permanece interativa para que senha/hash não sejam publicados no GitHub.

## Atenção ao disco

O arquivo `autoinstall-vm.yaml` usa:

```yaml
storage:
  layout:
    name: direct
```

Isso usa o disco inteiro apresentado ao instalador.

Em uma VM do Hyper-V, isso significa o VHDX da VM. **Não use esse perfil em máquina física sem revisar a seção `storage`.**

## Depois da instalação

Quando o Ubuntu terminar, reinicie a VM.

Se a VM iniciar novamente pela ISO, remova a ISO da unidade de DVD virtual ou coloque o disco VHDX acima do DVD na ordem de boot.

No primeiro login:

```bash
sudo apt update
sudo apt full-upgrade -y
```

Valide as ferramentas básicas:

```bash
git --version
python3 --version
ssh -V
gcc --version
```

Depois clone o projeto:

```bash
git clone https://github.com/Pedrinho2018/ubuntu-dev-ai-workstation.git
cd ubuntu-dev-ai-workstation
chmod +x setup.sh scripts/*.sh
./setup.sh
```

Na VM, use o perfil completo se quiser preparar o laboratório.

> Não instale o módulo NVIDIA dentro da VM. O teste de GTX/CUDA deve ser feito no host físico ou em uma solução específica de passthrough/GPU virtualization.
