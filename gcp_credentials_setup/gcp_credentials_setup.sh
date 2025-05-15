#!/bin/bash

# Descobre o nome do usuário do Windows de forma universal
WINUSER=$(powershell.exe '$env:UserName' | tr -d '\r')

# Local dos downloads no Windows (ajuste se seu caminho for diferente)
DOWNLOADS="/mnt/c/Users/$WINUSER/Downloads"

# Destino seguro para a credencial
DEST="$HOME/.gcp/credentials.json"

# Encontra o arquivo .json mais recente na pasta Downloads
SRC=$(ls -t "$DOWNLOADS"/*.json 2>/dev/null | head -n1)

if [[ -z "$SRC" ]]; then
  echo "❌ Nenhum arquivo .json encontrado em $DOWNLOADS"
  exit 1
fi

# Cria a pasta de destino se não existir
mkdir -p "$HOME/.gcp"

# Copia o arquivo e protege as permissões
cp "$SRC" "$DEST"
chmod 600 "$DEST"

echo "✅ Credencial copiada para $DEST"

# Garante que a variável de ambiente está no .zshrc (ou .bashrc)
if ! grep -q 'GOOGLE_APPLICATION_CREDENTIALS' ~/.zshrc; then
  echo 'export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.gcp/credentials.json"' >> ~/.zshrc
  echo "Variável GOOGLE_APPLICATION_CREDENTIALS adicionada ao ~/.zshrc"
else
  echo "Variável GOOGLE_APPLICATION_CREDENTIALS já está configurada no ~/.zshrc"
fi

echo "Rode 'source ~/.zshrc' para recarregar a variável (ou reinicie o terminal)."
