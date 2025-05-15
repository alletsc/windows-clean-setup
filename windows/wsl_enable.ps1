# Caminho do arquivo de log
$logPath = "$PSScriptRoot\wsl_enable_log.txt"

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

Write-Log "Enabling required Windows features for WSL..." "Yellow"
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
Write-Log "WSL and Virtual Machine Platform features enabled. System will reboot in 5 seconds..." "Cyan"
Start-Sleep -Seconds 5
Restart-Computer
