# 👥 Guía de Configuración para el Equipo

Esta guía específica está diseñada para nuestro equipo que trabaja con Windows y Linux.

## 🚀 Setup Rápido por Plataforma

### Para usuarios de Linux

```bash
git clone <tu-repositorio>
cd flutter-docker-dev
chmod +x setup.sh
./setup.sh
```

### Para usuarios de Windows

```cmd
git clone <tu-repositorio>
cd flutter-docker-dev
setup.bat
```

## 🔄 Archivos de configuración por plataforma

### Linux (Ubuntu/Fedora/Arch)
- Usa: `docker-compose.yml` (configuración por defecto)
- Script: `setup.sh`

### Windows (Docker Desktop)
- Usa: `docker-compose.windows.yml` si tienes problemas con la configuración por defecto
- Script: `setup.bat`
- Comando alternativo: `docker-compose -f docker-compose.windows.yml up -d`

## 📱 Configuración de Dispositivos Android

### Dispositivos del equipo testeados:

#### Xiaomi (idVendor: 18d1)
- **Linux**: Regla udev incluida en setup.sh
- **Windows**: Descargar Mi USB Driver

#### Samsung (idVendor: 04e8)  
- **Linux**: Añadir regla udev manualmente
- **Windows**: Samsung USB Driver (incluido en Samsung Smart Switch)

#### Google Pixel (idVendor: 18d1)
- **Linux**: Regla udev incluida en setup.sh  
- **Windows**: Google USB Driver

### Configuración rápida por fabricante:

```bash
# Linux - ejecutar según tu dispositivo
# Xiaomi/Google
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules

# Samsung  
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules

# Aplicar cambios
sudo udevadm control --reload-rules && sudo udevadm trigger
```

## 🛠️ Comandos del día a día

### Iniciar el entorno
```bash
# Linux
docker-compose up -d

# Windows (si hay problemas)
docker-compose -f docker-compose.windows.yml up -d
```

### Conectarse al contenedor
```bash
docker-compose exec flutter bash
```

### Crear nuevo proyecto
```bash
# Dentro del contenedor
flutter create nombre_proyecto
cd nombre_proyecto
```

### Ejecutar en dispositivo
```bash
# Verificar dispositivos
flutter devices

# Ejecutar
flutter run
```

### Detener el entorno
```bash
docker-compose down
```

## 🆘 Solución rápida de problemas

### "ADB device not found"

**Linux:**
```bash
# Fuera del contenedor
adb kill-server && adb start-server
adb devices
```

**Windows:**
```cmd
# En PowerShell de Windows
adb kill-server
adb start-server  
adb devices
```

### "Flutter SDK not found"

```bash
# Reconstruir imagen
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### "Cannot connect to Docker daemon"

**Linux:**
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar
```

**Windows:**
- Iniciar Docker Desktop
- Verificar que WSL2 está habilitado

## 📋 Checklist para nuevos miembros del equipo

### ✅ Requisitos previos
- [ ] Docker instalado (Docker Desktop en Windows)
- [ ] Git configurado
- [ ] VS Code instalado
- [ ] Extensión Dev Containers en VS Code

### ✅ Configuración inicial
- [ ] Clonar repositorio
- [ ] Ejecutar script de setup (setup.sh o setup.bat)
- [ ] Verificar que el contenedor inicia: `docker-compose ps`
- [ ] Probar Flutter: `docker-compose exec flutter flutter doctor`

### ✅ Test con dispositivo
- [ ] Conectar dispositivo Android
- [ ] Habilitar depuración USB
- [ ] Verificar detección: `adb devices`
- [ ] Crear proyecto de prueba
- [ ] Ejecutar en dispositivo: `flutter run`

### ✅ VS Code
- [ ] Abrir proyecto en VS Code
- [ ] Comando: "Dev Containers: Reopen in Container"
- [ ] Verificar extensiones Flutter y Dart instaladas
- [ ] Probar hot reload

## 🔗 Enlaces útiles del equipo

- **Repositorio**: `<tu-repositorio>`
- **Documentación Flutter**: https://flutter.dev/docs
- **Docker Desktop**: https://www.docker.com/products/docker-desktop
- **VS Code**: https://code.visualstudio.com/

## 💬 Soporte del equipo

Si tienes problemas:
1. Revisa esta guía y el README.md
2. Busca en los issues del repositorio
3. Pregunta en el canal de desarrollo del equipo
4. Crea un issue si es un problema nuevo

## 🔄 Actualizaciones

Para mantener tu entorno actualizado:

```bash
# Obtener últimos cambios
git pull

# Reconstruir si hay cambios en Docker
docker-compose build

# Reiniciar contenedor
docker-compose up -d
```

---

**¡Bienvenido al equipo! 🎉**
