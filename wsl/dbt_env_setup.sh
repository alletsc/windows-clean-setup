#!/bin/bash

set -e

# Checagem básica para não rodar fora do WSL/Ubuntu
if ! grep -qi microsoft /proc/version && [ "$(uname -s)" != "Linux" ]; then
  echo "❌ Este script foi feito para Ubuntu/WSL! Abortando."
  exit 1
fi

echo "🔧 Atualizando pacotes..."
sudo apt update -y && sudo apt upgrade -y

echo "📦 Instalando dependências essenciais para build de Python..."
sudo apt install -y make build-essential libssl-dev zlib1g-dev \
  libbz2-dev libreadline-dev libsqlite3-dev curl git \
  libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
  libffi-dev liblzma-dev unzip

echo "📂 Instalando pyenv (gerenciador de versões do Python)..."
if [ ! -d "$HOME/.pyenv" ]; then
  curl https://pyenv.run | bash
else
  echo "pyenv já está instalado."
fi

# Configuração do pyenv no shell (zsh ou bash)
SHELL_RC="$HOME/.zshrc"
[ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ] || SHELL_RC="$HOME/.bashrc"
if ! grep -q 'pyenv config' "$SHELL_RC"; then
  echo -e '\n# pyenv config' >> "$SHELL_RC"
  echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$SHELL_RC"
  echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> "$SHELL_RC"
  echo 'eval "$(pyenv init --path)"' >> "$SHELL_RC"
  echo 'eval "$(pyenv init -)"' >> "$SHELL_RC"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Instalação segura do Python 3.12 (se não existir)
if ! pyenv versions | grep -q "3.12.0"; then
  echo "🐍 Instalando Python 3.12 via pyenv..."
  pyenv install 3.12.0
fi
pyenv global 3.12.0

# Garante que pip está atualizado
python -m pip install --upgrade pip

# Ambiente virtual universal
VENV_PATH="$HOME/dbt-env"
if [ ! -d "$VENV_PATH" ]; then
  echo "🧪 Criando ambiente virtual dbt-env..."
  python -m venv "$VENV_PATH"
fi

echo "✅ Ativando ambiente virtual..."
source "$VENV_PATH/bin/activate"

echo "📦 Instalando DBT + adaptador BigQuery..."
pip install --upgrade dbt-core dbt-bigquery

# Estrutura universal de projetos DBT
PROJ_ROOT="$HOME/projects/dbt"
mkdir -p "$PROJ_ROOT"
cd "$PROJ_ROOT"
if [ ! -d "exemplo-projeto" ]; then
  echo "📁 Criando estrutura básica de projeto DBT..."
  dbt init exemplo-projeto
else
  echo "Projeto DBT 'exemplo-projeto' já existe."
fi

echo
echo "✅ Instalação finalizada com sucesso!"
echo "ℹ️ Para ativar o ambiente depois, use:"
echo "    source ~/dbt-env/bin/activate"
echo "🔁 Para desativar: deactivate"
