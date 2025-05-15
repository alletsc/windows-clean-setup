@echo off
setlocal
set "scriptdir=%~dp0"

echo ---------------------------------------------
echo Selecione a etapa que deseja executar:
echo 1 - Habilitar WSL e reiniciar (primeira vez)
echo 2 - Instalar Ubuntu no WSL 2 (após reboot)
set /p opcao="Digite 1 ou 2 e pressione Enter: "

if "%opcao%"=="1" (
    powershell -ExecutionPolicy Bypass -NoExit -File "%scriptdir%wsl_enable.ps1"
    pause
    exit /b
)

if "%opcao%"=="2" (
    powershell -ExecutionPolicy Bypass -NoExit -File "%scriptdir%wsl_ubuntu_install.ps1"
    pause
    exit /b
)

echo Opcao invalida. Execute novamente e digite 1 ou 2.
pause
