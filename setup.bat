@echo off
REM Script de configuración automática para Flutter Docker Development Environment (Windows)
REM Versión: 1.0

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║             Flutter Docker Development Environment             ║
echo ║                    Configuración Automática                   ║
echo ║                          Windows                               ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

echo [INFO] Verificando dependencias...

REM Verificar Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker no está instalado o no está en el PATH.
    echo         Por favor, instala Docker Desktop para Windows:
    echo         https://docs.docker.com/desktop/install/windows-install/
    pause
    exit /b 1
)

REM Verificar Docker Compose
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker Compose no está instalado.
    echo         Asegúrate de que Docker Desktop esté actualizado.
    pause
    exit /b 1
)

echo [SUCCESS] Docker y Docker Compose están instalados

REM Verificar que Docker está corriendo
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Docker no está ejecutándose.
    echo         Por favor, inicia Docker Desktop primero.
    pause
    exit /b 1
)

echo [SUCCESS] Docker está ejecutándose correctamente

REM Verificar ADB
adb version >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] ADB no está instalado o no está en el PATH.
    echo           Para usar dispositivos Android físicos, necesitas:
    echo           1. Instalar Android Studio, o
    echo           2. Descargar Platform Tools de Android:
    echo              https://developer.android.com/studio/releases/platform-tools
    echo           3. Añadir ADB al PATH del sistema
    echo.
    echo [INFO] Continuando sin ADB...
) else (
    echo [SUCCESS] ADB está disponible
)

REM Construir el entorno Docker
echo [INFO] Construyendo el entorno Docker (esto puede tardar varios minutos)...
docker-compose build
if %errorlevel% neq 0 (
    echo [ERROR] Error al construir la imagen Docker
    pause
    exit /b 1
)

echo [SUCCESS] Imagen Docker construida correctamente

REM Iniciar el contenedor
echo [INFO] Iniciando el contenedor...
docker-compose up -d
if %errorlevel% neq 0 (
    echo [ERROR] Error al iniciar el contenedor
    pause
    exit /b 1
)

echo [SUCCESS] Contenedor iniciado correctamente

REM Verificar que Flutter está funcionando
echo [INFO] Verificando instalación de Flutter...
docker-compose exec -T flutter flutter --version
if %errorlevel% neq 0 (
    echo [ERROR] Error al verificar Flutter
    docker-compose down
    pause
    exit /b 1
)

echo [SUCCESS] Flutter está funcionando correctamente

REM Verificar flutter doctor
echo [INFO] Ejecutando flutter doctor...
docker-compose exec -T flutter flutter doctor

REM Mostrar dispositivos conectados si ADB está disponible
adb version >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Verificando dispositivos conectados...
    echo.
    echo Dispositivos ADB en el host:
    adb devices
    echo.
)

echo Dispositivos detectados por Flutter:
docker-compose exec -T flutter flutter devices

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                    🎉 ¡Configuración Completa! 🎉            ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Tu entorno de desarrollo Flutter con Docker está listo para usar.
echo.
echo Próximos pasos:
echo 1. Para conectarte al contenedor: docker-compose exec flutter bash
echo 2. Para crear un nuevo proyecto: flutter create mi_app
echo 3. Para abrir en VS Code: Abre este directorio en VS Code y usa 'Reopen in Container'
echo.
echo IMPORTANTE para dispositivos Android en Windows:
echo - Asegúrate de tener los drivers USB del fabricante instalados
echo - Habilita la depuración USB en tu dispositivo
echo - Acepta el diálogo de permisos en el dispositivo
echo - Si usas WSL2, los dispositivos USB pueden requerir configuración adicional
echo.
echo Para más información, consulta el README.md
echo.
echo [SUCCESS] ¡Happy coding! 🚀

pause
