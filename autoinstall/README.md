# Autoinstall

Este diretório contém perfis de instalação automatizada para Ubuntu Desktop.

## Perfil de teste no Hyper-V

Arquivo: `autoinstall-vm.yaml`

Ele foi preparado para uma VM Ubuntu 26.04 Desktop com:

- idioma `pt_BR.UTF-8`
- teclado brasileiro
- timezone `America/Cuiaba`
- Ubuntu Desktop completo
- SSH habilitado
- Git, curl, wget, Python 3 e ferramentas de compilação
- atualizações de segurança
- drivers de terceiros desativados dentro da VM

## Segurança

A criação de usuário fica **interativa** de propósito. Assim, nenhuma senha ou hash de senha é publicada no GitHub.

⚠️ O perfil `autoinstall-vm.yaml` usa o layout de armazenamento `direct`, portanto utiliza o disco inteiro apresentado ao instalador.

Use este perfil apenas em VM/laboratório. Antes de usar em máquina física, revise a seção `storage`.

Nunca coloque no repositório:

- senhas
- tokens
- chaves SSH privadas
- arquivos de VPN com credenciais
- certificados privados

## Fluxo de teste

1. Inicie a VM pelo ISO do Ubuntu 26.04 Desktop.
2. Escolha **Instalar Ubuntu**.
3. Escolha **Automatizado com arquivo de instalação automática**.
4. Carregue `autoinstall-vm.yaml` a partir de outra mídia ou de um servidor web acessível pela VM.
5. O instalador deve pedir apenas os dados da conta do usuário.
6. Revise o resumo da instalação antes de confirmar.
7. Após o primeiro boot, clone este repositório e execute `./setup.sh` para instalar os módulos adicionais.
