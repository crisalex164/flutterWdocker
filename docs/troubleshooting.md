# 🔧 Solución de Problemas

Esta guía contiene soluciones para los problemas más comunes al usar el entorno Flutter Docker.

## 📱 Problemas con Dispositivos Android

### Dispositivo no detectado

**Síntomas:**
- `adb devices` no muestra tu dispositivo
- `flutter devices` no lista tu dispositivo Android
- Error: "No devices found"

**Soluciones para Linux:**

1. **Verifica la conexión física:**
   ```bash
   # En el host
   lsusb | grep -i "google\|samsung\|xiaomi\|huawei"
   ```

2. **Comprueba las reglas udev:**
   ```bash
   # Verifica que existen las reglas
   ls -la /etc/udev/rules.d/51-android*.rules
   
   # Si no existen, créalas
   echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

**Soluciones para Windows:**

1. **Verifica los drivers USB:**
   - Abre el Administrador de dispositivos
   - Busca tu dispositivo en "Dispositivos portátiles"
   - Si aparece con signo de exclamación, actualiza los drivers

2. **Instala drivers específicos del fabricante:**
   - **Samsung**: Samsung USB Driver
   - **Xiaomi**: Mi USB Driver  
   - **Google**: Google USB Driver
   - **Otros**: Busca drivers específicos o usa Universal ADB Driver

3. **Reinicia ADB:**
   ```cmd
   adb kill-server
   adb start-server
   adb devices
   ```

4. **Verifica permisos en el dispositivo:**
   - Asegúrate de que la depuración USB está habilitada
   - Acepta el diálogo de autorización en el dispositivo
   - Marca "Permitir siempre desde este ordenador"

### Error "device unauthorized"

**Solución:**
1. Revoca las autorizaciones USB en el dispositivo:
   - Configuración → Opciones de desarrollador → Revocar autorizaciones de depuración USB
2. Desconecta y reconecta el dispositivo
3. Acepta el nuevo diálogo de autorización

### Error "device offline"

**Solución:**
```bash
adb kill-server
adb start-server
# Si persiste:
adb disconnect
adb connect <dispositivo>
```

## 🐳 Problemas con Docker

### Error "Cannot connect to the Docker daemon"

**Síntomas:**
- Docker commands fallan con errores de conexión

**Soluciones:**

1. **Verifica que Docker está ejecutándose:**
   ```bash
   sudo systemctl status docker
   sudo systemctl start docker
   ```

2. **Añade tu usuario al grupo docker:**
   ```bash
   sudo usermod -aG docker $USER
   # Cierra sesión y vuelve a entrar
   ```

3. **Verifica permisos del socket:**
   ```bash
   sudo chmod 666 /var/run/docker.sock
   ```

### Error "failed to solve: process did not complete successfully"

**Síntomas:**
- La construcción de la imagen Docker falla

**Soluciones:**

1. **Limpia la caché de Docker:**
   ```bash
   docker system prune -a
   docker-compose build --no-cache
   ```

2. **Verifica espacio en disco:**
   ```bash
   df -h
   docker system df
   ```

3. **Aumenta memoria asignada a Docker** (Docker Desktop)

### Contenedor no inicia

**Síntomas:**
- `docker-compose up -d` falla
- Contenedor se detiene inmediatamente

**Soluciones:**

1. **Revisa los logs:**
   ```bash
   docker-compose logs
   ```

2. **Verifica la configuración:**
   ```bash
   docker-compose config
   ```

3. **Inicia sin daemon para ver errores:**
   ```bash
   docker-compose up
   ```

## 💻 Problemas con VS Code

### Dev Containers no funciona

**Síntomas:**
- VS Code no puede conectarse al contenedor
- Error "Failed to create container"

**Soluciones:**

1. **Actualiza la extensión Dev Containers:**
   - Ve a Extensions → Dev Containers → Update

2. **Verifica la configuración:**
   ```bash
   # Valida JSON
   cat .devcontainer/devcontainer.json | jq
   ```

3. **Reconstruye el contenedor:**
   - Ctrl+Shift+P → "Dev Containers: Rebuild Container"

4. **Usa attach en lugar de reopen:**
   - Inicia el contenedor manualmente: `docker-compose up -d`
   - Usa "Attach to Running Container" en VS Code

### Extensiones no se instalan automáticamente

**Soluciones:**

1. **Instala manualmente:**
   - Una vez en el contenedor, ve a Extensions
   - Instala "Flutter" y "Dart"

2. **Verifica la configuración en devcontainer.json:**
   ```json
   "customizations": {
     "vscode": {
       "extensions": [
         "dart-code.dart-code",
         "dart-code.flutter"
       ]
     }
   }
   ```

### Performance lenta en VS Code

**Soluciones:**

1. **Excluye directorios innecesarios:**
   ```json
   "files.exclude": {
     "**/.dart_tool": true,
     "**/build": true
   }
   ```

2. **Usa volúmenes nombrados** para dependencias grandes

3. **Aumenta recursos de Docker** si usas Docker Desktop

## 🔄 Problemas con Flutter

### Error "Flutter SDK not found"

**Síntomas:**
- Flutter commands no funcionan
- Error sobre SDK path

**Soluciones:**

1. **Verifica la instalación en el contenedor:**
   ```bash
   docker-compose exec flutter which flutter
   docker-compose exec flutter flutter --version
   ```

2. **Verifica variables de entorno:**
   ```bash
   docker-compose exec flutter echo $PATH
   ```

3. **Reconstruye la imagen:**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```

### Error "Unable to locate Android SDK"

**Soluciones:**

1. **Verifica la variable ANDROID_SDK_ROOT:**
   ```bash
   docker-compose exec flutter echo $ANDROID_SDK_ROOT
   ```

2. **Verifica que el SDK está instalado:**
   ```bash
   docker-compose exec flutter ls -la $ANDROID_SDK_ROOT
   ```

### Problemas con dependencias (pub get fails)

**Soluciones:**

1. **Limpia la caché:**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Verifica conectividad:**
   ```bash
   docker-compose exec flutter ping pub.dev
   ```

3. **Usa caché offline si es necesario:**
   ```bash
   flutter pub get --offline
   ```

## 🌐 Problemas de Red

### No hay conectividad a internet en el contenedor

**Soluciones:**

1. **Verifica DNS:**
   ```bash
   docker-compose exec flutter nslookup google.com
   ```

2. **Configura DNS manualmente:**
   ```yaml
   # En docker-compose.yml
   services:
     flutter:
       dns:
         - 8.8.8.8
         - 8.8.4.4
   ```

3. **Verifica firewall del host**

### Problemas con proxy corporativo

**Soluciones:**

1. **Configura proxy en Docker:**
   ```bash
   # En ~/.docker/config.json
   {
     "proxies": {
       "default": {
         "httpProxy": "http://proxy:port",
         "httpsProxy": "http://proxy:port"
       }
     }
   }
   ```

2. **Variables de entorno en el contenedor:**
   ```yaml
   environment:
     - HTTP_PROXY=http://proxy:port
     - HTTPS_PROXY=http://proxy:port
   ```

## 🪟 Problemas específicos de Windows

### Docker Desktop no inicia

**Síntomas:**
- Error al ejecutar comandos Docker
- Docker Desktop no se abre

**Soluciones:**

1. **Verifica WSL2:**
   ```powershell
   wsl --list --verbose
   wsl --set-default-version 2
   ```

2. **Habilita Hyper-V y Containers:**
   - Panel de Control → Programas → Activar características de Windows
   - Marca Hyper-V y Containers

3. **Actualiza Docker Desktop** a la última versión

### Problemas con dispositivos USB en WSL2

**Síntomas:**
- ADB no detecta dispositivos en WSL2
- Error "device not found" en contenedor

**Soluciones:**

1. **Usa ADB desde Windows, no desde WSL:**
   ```cmd
   # En PowerShell/CMD de Windows
   adb devices
   ```

2. **Configura port forwarding:**
   ```cmd
   # En Windows
   adb kill-server
   adb -a nodaemon server start
   ```

3. **Considera usar docker-compose.windows.yml:**
   ```cmd
   docker-compose -f docker-compose.windows.yml up -d
   ```

### Performance lenta en Windows

**Soluciones:**

1. **Usa volúmenes nombrados** para mejor performance:
   - Ya configurado en el docker-compose.yml

2. **Configura Docker Desktop:**
   - Settings → Resources → ajusta memoria y CPU
   - Settings → General → habilita "Use the WSL 2 based engine"

3. **Excluye directorios del antivirus:**
   - Añade la carpeta del proyecto a exclusiones de Windows Defender

## 🐧 Problemas específicos de Linux

### Script de diagnóstico rápido

```bash
#!/bin/bash
echo "=== Diagnóstico Flutter Docker ==="
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker-compose --version)"
echo "Contenedor estado: $(docker-compose ps)"
echo "ADB devices: $(adb devices)"
echo "Flutter devices: $(docker-compose exec -T flutter flutter devices)"
echo "Flutter doctor: $(docker-compose exec -T flutter flutter doctor)"
```

### Logs útiles

```bash
# Logs del contenedor
docker-compose logs -f

# Logs específicos de ADB
docker-compose exec flutter adb logcat

# Logs de Flutter
docker-compose exec flutter flutter logs
```

## 📞 ¿Necesitas más ayuda?

Si tu problema no está listado aquí:

1. **Revisa los [Issues cerrados](../../issues?q=is%3Aissue+is%3Aclosed)**
2. **Busca en la documentación oficial de [Flutter](https://flutter.dev/docs)**
3. **Crea un nuevo [Issue](../../issues/new/choose)** con toda la información relevante

**Información útil para incluir en un issue:**
- Sistema operativo y versión
- Versión de Docker y Docker Compose
- Modelo de dispositivo Android
- Logs completos del error
- Pasos exactos para reproducir el problema
