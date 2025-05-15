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

function Show-Spinner {
    param (
        [Parameter(Mandatory)][ScriptBlock]$ScriptBlock,
        [string]$Message = "Processing"
    )
    $spinner = "|/-\"
    $i = 0
    $job = Start-Job -ScriptBlock $ScriptBlock
    while ($job.State -eq 'Running') {
        Write-Host -NoNewline ("`r$Message " + $spinner[$i % $spinner.Length])
        Start-Sleep -Milliseconds 200
        $i++
    }
    Write-Host "`r$Message... done!"
    Receive-Job $job
    Remove-Job $job
}

Write-Log "Iniciando instalação do WSL 2 e Ubuntu..." "Cyan"

# Instala WSL e Ubuntu mais recente
Write-Log "Executando: wsl --install -d Ubuntu (isso pode demorar vários minutos, aguarde...)" "Yellow"
Show-Spinner -Message "Instalando Ubuntu no WSL2" -ScriptBlock { wsl --install -d Ubuntu | Out-Null }

# Atualiza kernel do WSL
Write-Log "Atualizando kernel do WSL (se necessário)..." "Yellow"
wsl --update | Tee-Object -FilePath $logPath -Append

# Lista distros disponíveis (opcional, só log)
Write-Log "Listando distribuições disponíveis para instalação..." "Yellow"
wsl --list --online | Tee-Object -FilePath $logPath -Append

# Checa se Ubuntu está instalado
$distros = wsl --list --quiet
if ($distros -match "Ubuntu") {
    Write-Log "✅ Ubuntu instalado com sucesso no WSL2!" "Green"
} else {
    Write-Log "❌ Ubuntu NÃO foi encontrado após instalação! Tente instalar manualmente pela Microsoft Store." "Red"
    exit 1
}

# Encerra o WSL
Write-Log "Encerrando todas as instâncias WSL..." "Yellow"
wsl --shutdown

Write-Log "✅ Instalação completa! O computador será reiniciado em 10 segundos..." "Green"
Start-Sleep -Seconds 10
Restart-Computer
