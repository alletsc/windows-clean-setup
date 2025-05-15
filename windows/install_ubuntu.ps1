# Instala o WSL 2 e o Ubuntu mais recente
wsl --install -d Ubuntu

# Atualiza kernel do WSL se necessário
wsl --update

# (Opcional) Lista as distros disponíveis
wsl --list --online

# Encerra o WSL antes de reiniciar
wsl --shutdown

Write-Host "WSL 2 e Ubuntu instalados com sucesso. O computador será reiniciado em 10 segundos..."
Start-Sleep -Seconds 10
Restart-Computer
