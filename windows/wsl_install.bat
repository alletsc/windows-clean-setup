@echo off
setlocal
set "scriptdir=%~dp0"
set "flag1=%scriptdir%wsl_enable_done.flag"

:: Testa se script 1 já rodou
if not exist "%flag1%" (
    echo [INFO] Running WSL enable script (as admin)...
    net session >nul 2>&1
    if %errorlevel% neq 0 (
        powershell -Command "Start-Process '%~f0' -Verb RunAs"
        exit /b
    )
    powershell -ExecutionPolicy Bypass -NoExit -File "%scriptdir%wsl_enable.ps1"
    echo.>"%flag1%"
    echo [INFO] WSL enable done. Rebooting...
    pause
    exit /b
)

:: Script 1 já rodou, chama o script 2
echo [INFO] Running Ubuntu install script (as admin)...
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
powershell -ExecutionPolicy Bypass -NoExit -File "%scriptdir%wsl_ubuntu_install.ps1"
pause
