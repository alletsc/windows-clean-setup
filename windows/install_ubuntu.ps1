# Caminho do arquivo de log
$logPath = "$PSScriptRoot\wsl_install_log.txt"
function Write-Log {
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        [string]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] $Message"
    Add-Content -Path $logPath -Value $entry
    Write-Host $Message -ForegroundColor $Color
}

Write-Log "Iniciando instalação do WSL 2 e Ubuntu..." "Cyan"

# Instala WSL e Ubuntu mais recente (no Windows 11, já instala o kernel mais novo)
Write-Log "Executando: wsl --install -d Ubuntu" "Yellow"
wsl --install -d Ubuntu | Tee-Object -FilePath $logPath -Append

# Atualiza kernel do WSL
Write-Log "Atualizando kernel do WSL (se necessário)..." "Yellow"
wsl --update | Tee-Object -FilePath $logPath -Append

# Lista distros disponíveis (opcional, só log)
Write-Log "Listando distribuições disponíveis para instalação..." "Yellow"
wsl --list --online | Tee-Object -FilePath $logPath -Append

# Encerra o WSL
Write-Log "Encerrando todas as instâncias WSL..." "Yellow"
wsl --shutdown

Write-Log "✅ WSL 2 e Ubuntu instalados com sucesso! O computador será reiniciado em 10 segundos..." "Green"
Start-Sleep -Seconds 10
Restart-Computer

