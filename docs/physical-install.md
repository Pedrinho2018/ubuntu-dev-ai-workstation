# Instalação física — Ubuntu 26.04

Este guia é para instalar o Ubuntu no computador físico e depois preparar o ambiente com os scripts deste repositório.

## Importante

O arquivo `autoinstall/autoinstall-vm.yaml` foi criado para laboratório/Hyper-V e usa o disco inteiro apresentado ao instalador.

**Não use o perfil da VM para formatar a máquina física.**

Para a instalação física, a recomendação atual é fazer a instalação do Ubuntu de forma interativa e usar este projeto somente no pós-instalação.

## Antes de formatar

- Faça backup de documentos e projetos.
- Confirme que repositórios Git importantes foram enviados ao GitHub.
- Salve chaves SSH, certificados e arquivos de VPN em local seguro.
- Salve a chave de recuperação do BitLocker, se existir.
- Confirme que OneDrive/Google Drive terminou de sincronizar.
- Tenha uma mídia de recuperação do Windows disponível, caso precise voltar.

## Instalação do Ubuntu

1. Crie o pendrive bootável do Ubuntu 26.04.
2. Inicie o notebook pelo pendrive em modo UEFI.
3. Escolha `Instalar Ubuntu`.
4. Configure idioma, teclado e rede.
5. Escolha manualmente o disco/particionamento.
6. Só escolha `Apagar disco e instalar Ubuntu` se o objetivo realmente for remover todo o sistema existente.
7. Crie seu usuário e senha.
8. Conclua a instalação e reinicie.

## Pós-instalação

Depois do primeiro login:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y git

git clone https://github.com/Pedrinho2018/ubuntu-dev-ai-workstation.git
cd ubuntu-dev-ai-workstation
chmod +x setup.sh scripts/*.sh
./setup.sh
```

No menu, a opção recomendada é:

```text
11) Instalar MEU PERFIL PRINCIPAL
```

Depois execute o diagnóstico:

```bash
./setup.sh --check
```

## NVIDIA

O perfil principal não instala o driver NVIDIA automaticamente.

Depois de confirmar que o sistema está estável, execute:

```bash
./setup.sh
```

E selecione:

```text
10) NVIDIA (somente host físico)
```

O módulo detecta virtualização e se recusa a instalar driver NVIDIA dentro de VM.

## Administração Windows

Ubuntu não substitui as ferramentas RSAT/ADUC/GPMC do Windows. Este projeto instala ferramentas para administração remota, como Remmina/RDP, SSH, SMB, LDAP e PowerShell 7.

Para tarefas que exigem consoles nativos do Windows, use RDP em uma estação ou servidor Windows autorizado.
