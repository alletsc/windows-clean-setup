#!/bin/bash

# Garante execução apenas em WSL
if ! grep -qi microsoft /proc/version; then
  echo "❌ Este script foi feito para WSL2! Abortando."
  exit 1
fi

# Garante que .zshrc exista
[ -f "$HOME/.zshrc" ] || touch "$HOME/.zshrc"
ZSHRC="$HOME/.zshrc"

# Descobre usuário do Windows automaticamente
WINUSER=$(powershell.exe '$env:UserName' | tr -d '\r')

# Função para adicionar linhas únicas ao .zshrc
add_line() {
  grep -qxF "$1" "$ZSHRC" || echo "$1" >> "$ZSHRC"
}

echo "🔧 Atualizando sistema..."
sudo apt update -y && sudo apt upgrade -y

echo "🐚 Instalando Zsh, Git, fontes e utilitários básicos..."
sudo apt install -y zsh git curl unzip fontconfig

echo "💡 Tornando Zsh o shell padrão..."
chsh -s $(which zsh)

echo "🧱 Instalando ferramentas essenciais para compilação e desenvolvimento..."
sudo apt install -y build-essential pkg-config libssl-dev \
  libffi-dev libsqlite3-dev libbz2-dev libreadline-dev zlib1g-dev

echo "✨ Instalando Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "🚀 Instalando Starship..."
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

mkdir -p ~/.config
cat << 'EOF' > ~/.config/starship.toml
[package]
disabled = true

[python]
format = 'via [$symbol$pyenv_prefix($version )($virtualenv )]($style)'
version_format = 'v${raw}'
symbol = '🐍 '
style = 'yellow bold'
pyenv_version_name = true
pyenv_prefix = ''
python_binary = ['python', 'python3', 'python2']
detect_extensions = ['py']
detect_files = ['.python-version', 'Pipfile', '__init__.py', 'pyproject.toml', 'requirements.txt', 'setup.py', 'tox.ini']
detect_folders = []
disabled = false
EOF

add_line ""
add_line "# Inicializar Starship"
add_line 'export PATH="$HOME/.cargo/bin:$PATH"'
add_line 'eval "$(starship init zsh)"'

echo "📆 Instalando plugins do Oh My Zsh..."
PLUGDIR=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins
[ -d "$PLUGDIR" ] || mkdir -p "$PLUGDIR"
[ -d "$PLUGDIR/zsh-autosuggestions" ] || git clone https://github.com/zsh-users/zsh-autosuggestions $PLUGDIR/zsh-autosuggestions
[ -d "$PLUGDIR/zsh-syntax-highlighting" ] || git clone https://github.com/zsh-users/zsh-syntax-highlighting $PLUGDIR/zsh-syntax-highlighting

# Atualiza linha de plugins no .zshrc de modo seguro
if grep -q '^plugins=' "$ZSHRC"; then
  sed -i '/^plugins=/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' "$ZSHRC"
else
  echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$ZSHRC"
fi

add_line ""
add_line "# Alias para Python e venv"
add_line "alias python='python3'"
add_line "alias pip='pip3'"
add_line "alias create='python3 -m venv .venv'"
add_line "alias activate='source .venv/bin/activate'"

add_line ""
add_line "# Alias para abrir Cursor"
add_line "alias code=\"/mnt/c/Users/$WINUSER/AppData/Local/Programs/cursor/Cursor.exe\""

echo "🧽 Instalando Navi (cheatsheet + sugestões inteligentes)..."
if ! command -v navi >/dev/null 2>&1; then
  curl -sL https://raw.githubusercontent.com/denisidoro/navi/master/scripts/install | bash
fi

add_line 'export PATH="$HOME/.local/bin:$PATH"'
add_line 'alias helpme="navi"'

echo "⚡ Instalando Zoxide (cd inteligente)..."
if ! command -v zoxide >/dev/null 2>&1; then
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --yes
fi

add_line 'eval "$(zoxide init zsh)"'

add_line ""
add_line "# Aliases de navegação rápida com zoxide"
add_line "alias ..h='z ~'"
add_line "alias ..d='z \"/mnt/c/Users/$WINUSER/OneDrive/Área de Trabalho\"'"
add_line "alias ..docs='z \"/mnt/c/Users/$WINUSER/OneDrive/Documents\"'"
add_line "alias ..img='z \"/mnt/c/Users/$WINUSER/OneDrive/Pictures\"'"
add_line "alias ..dl='z \"/mnt/c/Users/$WINUSER/Downloads\"'"
add_line "alias ..disk='z \"/mnt/d\"'"

echo "🐙 Configurando Git global com boas práticas modernas..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.default current
git config --global core.excludesfile ~/.gitignore_global

cat << 'EOF' > ~/.gitignore_global
__pycache__/
.env
.venv/
.DS_Store
EOF

echo "📦 Instalando utilitários CLI úteis: jq, yq, tree, fzf..."
sudo apt install -y jq yq tree fzf

# Sincronização de relógio e timezone
echo "🕒 Sincronizando relógio e ajustando timezone..."
sudo hwclock -s || true
sudo timedatectl set-timezone America/Sao_Paulo

echo "⚙️ Aplicando tunagens de performance no .wslconfig..."
cat <<EOF > /mnt/c/Users/$WINUSER/.wslconfig
[wsl2]
memory=16GB
processors=6
swap=8GB
localhostForwarding=true
EOF

echo "✅ Arquivo .wslconfig criado com sucesso em C:\\Users\\$WINUSER\\.wslconfig"
echo "🔁 Execute 'wsl --shutdown' no PowerShell para aplicar as novas configurações."

echo "✅ Setup completo! Rode 'source ~/.zshrc' ou reinicie o terminal para aplicar tudo."
