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

Write-Log "Setting WSL 2 as default version..." "Yellow"
wsl --set-default-version 2

Write-Log "Trying to install Ubuntu via WSL..." "Yellow"
Show-Spinner -Message "Installing Ubuntu on WSL2" -ScriptBlock { wsl --install -d Ubuntu | Out-Null }

Start-Sleep -Seconds 3

# Check if Ubuntu was installed
$distros = wsl --list --quiet
if ($distros -notmatch "Ubuntu") {
    Write-Log "Ubuntu was not installed via 'wsl --install', trying installation via Microsoft Store (winget)..." "Yellow"
    winget install -e --id Canonical.Ubuntu | Tee-Object -FilePath $logPath -Append
    Write-Log "If you see 'Ubuntu installed', open Ubuntu from the Start Menu to finish setup (first run creates your Linux user)." "Cyan"
} else {
    Write-Log "✅ Ubuntu successfully installed on WSL2!" "Green"
}

Write-Log "Updating WSL kernel (if needed)..." "Yellow"
wsl --update | Tee-Object -FilePath $logPath -Append

Write-Log "Listing available distributions for installation..." "Yellow"
wsl --list --online | Tee-Object -FilePath $logPath -Append

Write-Log "Shutting down all WSL instances..." "Yellow"
wsl --shutdown

Write-Log "✅ Installation complete! The computer will restart in 10 seconds..." "Green"
Start-Sleep -Seconds 10
Restart-Computer
