@echo off
:: Executa o script como admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

powershell -ExecutionPolicy Bypass -NoExit -File "%~dp0setup_windows_limpo.ps1"
pause
