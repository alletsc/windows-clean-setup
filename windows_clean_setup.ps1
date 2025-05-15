# Executar como admin
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process PowerShell "-ExecutionPolicy Bypass -File `"%~dp0windows_clean_setup.ps1`"" -Verb RunAs
    exit
}

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
Write-Host "Aplicando configurações de limpeza e otimização do Windows..." -ForegroundColor Cyan

# Ativar modo escuro
$personalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
If (-Not (Test-Path $personalizePath)) { New-Item -Path $personalizePath -Force | Out-Null }
Set-ItemProperty -Path $personalizePath -Name "AppsUseLightTheme" -Value 0 -Force
Set-ItemProperty -Path $personalizePath -Name "SystemUsesLightTheme" -Value 0 -Force

# Ícones pequenos barra de tarefas
$advancedPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
If (-Not (Test-Path $advancedPath)) { New-Item -Path $advancedPath -Force | Out-Null }
Set-ItemProperty -Path $advancedPath -Name "TaskbarSi" -Value 0 -Force

# Desativar Widgets e Notícias
reg.exe add HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v TaskbarDa /t REG_DWORD /d 0 /f
reg.exe add HKLM\SOFTWARE\Policies\Microsoft\Dsh /v AllowNewsAndInterests /t REG_DWORD /d 0 /f
reg.exe add HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f

# Remover busca online no menu iniciar
$policyPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
If (-Not (Test-Path $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
Set-ItemProperty -Path $policyPath -Name "DisableSearchBoxSuggestions" -Value 1 -Force

# Remover sugestões automáticas
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-338389Enabled" /t REG_DWORD /d 0 /f
reg.exe add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "SubscribedContent-310093Enabled" /t REG_DWORD /d 0 /f

# Remover apps inúteis
$apps = @(
  "*microsoft.todo*", "*bing*", "*news*", "*weather*", "*xbox*", "*skype*",
  "*solitaire*", "*officehub*", "*onenote*", "*yourphone*", "*clipchamp*"
)
foreach ($app in $apps) {
  Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# Instalar programas úteis se necessário (INCLUINDO GIT E POWERTOYS)
$appsToInstall = @{
  "Google.Chrome" = "chrome.exe"
  "OBSProject.OBSStudio" = "obs64.exe"
  "Google.GoogleDrive" = "googledrivesync.exe"
  "Klocman.BulkCrapUninstaller" = "BCUninstaller.exe"
  "valinet.explorerpatcher" = "ep_setup.exe"
  "Git.Git" = "git.exe"
  "Microsoft.PowerToys" = "PowerToys.exe"
}
foreach ($id in $appsToInstall.Keys) {
  $exe = $appsToInstall[$id]
  if (-not (Get-Command $exe -ErrorAction SilentlyContinue)) {
    Write-Host "Instalando $id..."
    winget install --id=$id -e --accept-source-agreements --accept-package-agreements
  } else {
    Write-Host "$id já está instalado. Pulando..."
  }
}

# Desabilitar Spotlight e aplicar plano de fundo fixo
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
$desktopViewKey = "HKCU:\Software\Microsoft\Windows\Shell\Bags\1\Desktop"
If (-Not (Test-Path $desktopViewKey)) { New-Item -Path $desktopViewKey -Force | Out-Null }
Set-ItemProperty -Path $desktopViewKey -Name "IconSize" -Value 32

# Instalar Nerd Fonts
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
Stop-Process -Name explorer -Force
Start-Sleep -Seconds 3
Start-Process explorer
Start-Sleep -Seconds 5
Write-Host "Finalizado. Reiniciando o sistema..."
Restart-Computer

# Tornar o Chrome o navegador e leitor de PDF padrão
Write-Host "Definindo Google Chrome como navegador e leitor de PDF padrão..."
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
Write-Host "Removendo o ícone 'Saiba mais sobre este plano de fundo' do desktop..."
Remove-Item "$env:USERPROFILE\Desktop\*Saiba mais sobre*" -Force -ErrorAction SilentlyContinue

# Remove dos desktops dos outros usuários (admin)
$users = Get-ChildItem "C:\Users" -Directory | Where-Object { Test-Path "$($_.FullName)\Desktop" }
foreach ($user in $users) {
    $file = Get-ChildItem "$($user.FullName)\Desktop" -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Saiba mais sobre*" }
    foreach ($f in $file) { Remove-Item $f.FullName -Force -ErrorAction SilentlyContinue }
}
