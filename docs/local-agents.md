# Agentes locais — Ubuntu

Esta funcionalidade e opcional: o perfil **--full** continua inalterado.
Arquitetura: **Ollama local** + **LangGraph com historico SQLite** + **n8n**
em Docker. O Letta fica como uma integracao futura, nao e instalado.

## Comandos no Ubuntu

~~~bash
./setup.sh --agents                  # Instala venv LangGraph
bash scripts/agents.sh install-ollama # Pede confirmacao antes de rodar instalador
bash scripts/agents.sh model-pull     # Faz download de qwen3:4b (var OLLAMA_MODEL)
bash scripts/agents.sh chat 'Ola, agente!'
bash scripts/agents.sh up             # Inicia n8n, requer Docker Compose v2
bash scripts/agents.sh status
bash scripts/agents.sh down           # Preserva volume de dados
~~~

Para o modelo personalizado do Hermes, defina a variavel OLLAMA_MODEL com o
nome exato mostrado por **ollama list**. O modelo deve estar instalado localmente.

## Seguranca

- O chat Python nao possui ferramentas de shell, acesso SSH nem execucao de comandos.
  Adicione essas capacidades somente com aprovacoes e politicas de acesso.
- O historico local fica sob ~/.local/state/ubuntu-dev-ai-workstation/agents,
  com permissoes restritas. Nao envie credenciais ou dados sigilosos ao agente.
- n8n escuta **somente** em 127.0.0.1:5678. Crie a conta no primeiro acesso.
  Para acesso remoto, use tunel SSH ou HTTPS com autenticacao.
- A chave aleatoria n8n e armazenada em compose/.env.agents, ignorado pelo Git.
  Faca backup seguro desse arquivo E do volume Docker n8n_data. Sem a chave
  original, credenciais armazenadas no n8n podem nao ser recuperaveis.
- A tag n8nio/n8n:latest e apenas para laboratorio. Fixe N8N_IMAGE em uma
  versao validada para producao.
- O instalador do Ollama e obtido de https://ollama.com/install.sh e solicita
  confirmacao. Modelo nao e baixado automaticamente durante --full.
- O grupo docker concede privilegios elevados: apenas usuarios confiaveis.
- Memoria Letta e uma avaliacao futura: https://docs.letta.com/quickstart

## Validacao automatizada

GitHub Actions valida sintaxe Bash/Python, ShellCheck e Docker Compose.
Ele nao acessa seu Ubuntu nem instala modelos na maquina.
