@echo off
title SMAAR - Servidor
color 0A

echo ================================================
echo   SMAAR - Iniciando Servidor Django + Ngrok
echo ================================================
echo.

:: Verifica se o ngrok esta instalado
where ngrok >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] ngrok nao encontrado no PATH.
    echo Baixe em: https://ngrok.com/download e adicione ao PATH.
    echo.
    pause
    exit /b 1
)

echo [1/2] Iniciando tunel Ngrok...
echo       URL publica: https://seu-dominio.ngrok-free.app
echo.
start "SMAAR - Ngrok" cmd /k "ngrok http --domain=seu-dominio.ngrok-free.app 8000"

:: Pequena espera para o Ngrok inicializar
timeout /t 3 /nobreak >nul

echo [2/2] Iniciando servidor Django...
echo.
cd /d "%~dp0backend"

:: Tenta ativar o venv se existir
if exist "..\venv\Scripts\activate.bat" (
    call ..\venv\Scripts\activate.bat
) else if exist "venv\Scripts\activate.bat" (
    call venv\Scripts\activate.bat
)

echo ================================================
echo   Servidor rodando em: http://localhost:8000
echo   Acesso externo via:  https://seu-dominio.ngrok-free.app
echo   Pressione Ctrl+C para parar o Django
echo ================================================
echo.
python manage.py runserver 0.0.0.0:8000
pause