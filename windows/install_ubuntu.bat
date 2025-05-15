@echo off
:: Executa como admin, se necessário
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

powershell -ExecutionPolicy Bypass -NoExit -File "%~dp0install_wsl_ubuntu.ps1"
pause
