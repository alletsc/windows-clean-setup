# Executar como admin
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Start-Process PowerShell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
  exit
}

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

# Caminho do arquivo de log
$logPath = "$PSScriptRoot\setup_log.txt"

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

Write-Log "Aplicando configurações de limpeza e otimização do Windows..." "Cyan"

# ---------- Tunagens DEV E OTIMIZAÇÃO ----------

# 1. Desabilitar Telemetria e Cortana
Write-Log "Desabilitando telemetria e removendo Cortana..." "Yellow"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f
Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage -ErrorAction SilentlyContinue

# 2. Desabilitar inicialização rápida (evita bugs dual boot/WSL)
Write-Log "Desabilitando inicialização rápida..." "Yellow"
powercfg /h off
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 0 /f

# 3. Desabilitar serviço de telemetria
Write-Log "Desabilitando serviço DiagTrack..." "Yellow"
Stop-Service -Name "DiagTrack" -Force
Set-Service -Name "DiagTrack" -StartupType Disabled

# 4. Limpar arquivos temporários
Write-Log "Limpando arquivos temporários..." "Yellow"
del /q /s "$env:TEMP\*" | Out-Null
del /q /s "C:\Windows\Temp\*" | Out-Null

# 5. WSL 2 como padrão
Write-Log "Definindo WSL 2 como padrão..." "Yellow"
wsl --set-default-version 2

# 6. Instalar Terminal moderno
Write-Log "Instalando Windows Terminal..." "Yellow"
winget install --id=Microsoft.WindowsTerminal -e --accept-source-agreements --accept-package-agreements --silent | Tee-Object -FilePath $logPath -Append

# 7. Política de energia - alto desempenho
Write-Log "Ativando plano de energia de alto desempenho..." "Yellow"
powercfg -setactive SCHEME_MIN

# 8. Desabilitar atualização automática de drivers
Write-Log "Desabilitando atualização automática de drivers..." "Yellow"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching" /v SearchOrderConfig /t REG_DWORD /d 0 /f

# 9. Limpar apps provisionados (para novos usuários)
Write-Log "Removendo apps provisionados do Xbox para novos usuários..." "Yellow"
Get-AppxProvisionedPackage -Online | where DisplayName -like "*xbox*" | Remove-AppxProvisionedPackage -Online

# 10. Atualizar Windows Defender
Write-Log "Atualizando Windows Defender..." "Yellow"
Update-MpSignature | Tee-Object -FilePath $logPath -Append

# ---------- Seu script original ----------

# Ativar modo escuro
Write-Log "Ativando modo escuro..." "Yellow"
$personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
If (-Not (Test-Path $personalizePath)) { New-Item -Path $personalizePath -Force | Out-Null }
Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme" -Value 0 -Force
Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 0 -Force

# Ícones pequenos barra de tarefas
Write-Log "Ativando ícones pequenos na barra de tarefas..." "Yellow"
$advancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
If (-Not (Test-Path $advancedPath)) { New-Item -Path $advancedPath -Force | Out-Null }
Set-ItemProperty -Path $advancedPath -Name "TaskbarSi" -Value 0 -Force

# Desativar Widgets e Notícias
Write-Log "Desativando Widgets e Notícias..." "Yellow"
reg.exe add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarDa /t REG_DWORD /d 0 /f
reg.exe add HKLM\SOFTWARE\Policies\Microsoft\Dsh /v AllowNewsAndInterests /t REG_DWORD /d 0 /f
reg.exe add HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f

# Remover busca online no menu iniciar
Write-Log "Removendo busca online no menu iniciar..." "Yellow"
$policyPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
If (-Not (Test-Path $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
Set-ItemProperty -Path $policyPath -Name "DisableSearchBoxSuggestions" -Value 1 -Force

# Remover sugestões automáticas
Write-Log "Desabilitando sugestões automáticas..." "Yellow"
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f

# Remover apps inúteis
Write-Log "Removendo apps inúteis padrão..." "Yellow"
$apps = @(
  "*microsoft.todo*", "*bing*", "*news*", "*weather*", "*xbox*", "*skype*",
  "*solitaire*", "*officehub*", "*onenote*", "*yourphone*", "*clipchamp*"
)
foreach ($app in $apps) {
  Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Instalar ou atualizar programas úteis via Winget (incluindo Git e PowerToys)
$appsToInstall = @(
  "Google.Chrome",
  "OBSProject.OBSStudio",
  "Google.GoogleDrive",
  "Klocman.BulkCrapUninstaller",
  "valinet.explorerpatcher",
  "Git.Git",
  "Microsoft.PowerToys"
)
foreach ($id in $appsToInstall) {
  Write-Log "Instalando ou atualizando $id..." "Yellow"
  winget install --id=$id -e --accept-source-agreements --accept-package-agreements --silent | Tee-Object -FilePath $logPath -Append
}

# Desabilitar Spotlight e aplicar plano de fundo fixo
Write-Log "Desabilitando Spotlight e aplicando plano de fundo fixo..." "Yellow"
$wallpaperPath = "$env:SystemRoot\Web\Wallpaper\Windows\img0.jpg"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $wallpaperPath
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value "10"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value "0"
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "ContentDeliveryAllowed" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "FeatureManagementEnabled" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenEnabled" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD /d 0 /f
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters

# Ícones da área de trabalho pequenos
Write-Log "Definindo ícones pequenos na área de trabalho..." "Yellow"
$desktopViewKey = "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop"
If (-Not (Test-Path $desktopViewKey)) { New-Item -Path $desktopViewKey -Force | Out-Null }
Set-ItemProperty -Path $desktopViewKey -Name "IconSize" -Value 32

# Instalar Nerd Fonts
Write-Log "Instalando Nerd Fonts..." "Yellow"
$fontsPath = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
New-Item -ItemType Directory -Force -Path $fontsPath | Out-Null

function Install-FontFromZip($url, $tempName) {
  $zip = "$env:TEMP\$tempName.zip"
  $out = "$env:TEMP\$tempName"
  Invoke-WebRequest -Uri $url -OutFile $zip
  Expand-Archive -Path $zip -DestinationPath $out -Force
  Get-ChildItem -Path $out -Recurse -Include *.ttf | ForEach-Object {
      Copy-Item $_.FullName -Destination $fontsPath
  }
  Remove-Item $zip -Force
  Remove-Item $out -Recurse -Force
}

Install-FontFromZip -url "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip" -tempName "FiraCode"
Install-FontFromZip -url "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip" -tempName "JetBrainsMono"
Install-FontFromZip -url "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip" -tempName "Meslo"

# Reiniciar Explorer e sistema
Write-Log "Reiniciando Explorer..." "Yellow"
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 3
Start-Process explorer
Start-Sleep -Seconds 5

Write-Log "Finalizado. Reiniciando o sistema..." "Green"
Restart-Computer

# Tornar o Chrome o navegador e leitor de PDF padrão
Write-Log "Definindo Google Chrome como navegador e leitor de PDF padrão..." "Yellow"
$chromePath = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
if (!(Test-Path $chromePath)) {
  $chromePath = "${env:ProgramFiles}\Google\Chrome\Application\chrome.exe"
}
if (Test-Path $chromePath) {
  Start-Process -FilePath $chromePath -ArgumentList "--make-default-browser" -Wait
  Start-Process "ms-settings:defaultapps"
  Start-Process "ms-settings:defaultapps-app"
}

# Remover o atalho do Spotlight do desktop do usuário atual
Write-Log "Removendo o ícone 'Saiba mais sobre este plano de fundo' do desktop..." "Yellow"
Remove-Item "$env:USERPROFILE\Desktop\*Saiba mais sobre*" -Force -ErrorAction SilentlyContinue

# Remove dos desktops dos outros usuários (admin)
Write-Log "Removendo Spotlight dos desktops dos outros usuários..." "Yellow"
$users = Get-ChildItem "C:\Users" -Directory | Where-Object { Test-Path "$($_.FullName)\Desktop" }
foreach ($user in $users) {
  $file = Get-ChildItem "$($user.FullName)\Desktop" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Saiba mais sobre*" }
  foreach ($f in $file) { Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue }
}

# Abrir o arquivo de log ao final (antes do reboot, pois restart vai fechar tudo)
Start-Process notepad.exe $logPath
