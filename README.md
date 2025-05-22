# 🚀 Entorno de Desarrollo Flutter con Docker

Un entorno de desarrollo Flutter completamente containerizado y portable para desarrollo de aplicaciones móviles. Este setup permite trabajar con Flutter sin necesidad de instalarlo localmente, garantizando consistencia entre diferentes equipos y dispositivos.

## 📋 Tabla de Contenidos

- [Características](#características)
- [Requisitos Previos](#requisitos-previos)
- [Instalación Rápida](#instalación-rápida)
- [Configuración Detallada](#configuración-detallada)
- [Uso con Dispositivos Android](#uso-con-dispositivos-android)
- [Comandos Útiles](#comandos-útiles)
- [Desarrollo con VS Code](#desarrollo-con-vs-code)
- [Solución de Problemas](#solución-de-problemas)
- [Contribución](#contribución)

## ✨ Características

- **Flutter 3.24.4** con Dart SDK
- **Android SDK 34** preconfigurado
- **Soporte para dispositivos físicos** Android via USB
- **Integración completa con VS Code** mediante Dev Containers
- **Hot Reload y Hot Restart** funcionando
- **Volúmenes persistentes** para mantener el SDK y dependencias
- **Configuración optimizada** para desarrollo móvil

## 📦 Requisitos Previos

### Software necesario:
- [Docker](https://docs.docker.com/get-docker/) (versión 20.10 o superior)
- [Docker Compose](https://docs.docker.com/compose/install/) (versión 2.0 o superior)
- [Visual Studio Code](https://code.visualstudio.com/) (opcional pero recomendado)
- [Extensión Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) para VS Code

### Para desarrollo en dispositivos físicos:
- Dispositivo Android con depuración USB habilitada
- ADB instalado en el sistema host:
  - **Linux**: Se instala automáticamente en la mayoría de distribuciones
  - **Windows**: Se incluye con Android Studio o se puede instalar por separado

## 🚀 Instalación Rápida

1. **Clona este repositorio**:
   ```bash
   git clone https://github.com/tu-usuario/flutter-docker-dev.git
   cd flutter-docker-dev
   ```

2. **Construye y ejecuta el entorno**:
   ```bash
   docker-compose up -d --build
   ```

3. **Accede al contenedor**:
   ```bash
   docker-compose exec flutter bash
   ```

4. **Crea tu primer proyecto**:
   ```bash
   flutter create mi_app
   cd mi_app
   flutter run
   ```

## ⚙️ Configuración Detallada

### Estructura del proyecto

```
flutter-docker-dev/
├── Dockerfile              # Configuración de la imagen Docker
├── docker-compose.yml      # Configuración de servicios
├── .devcontainer/
│   └── devcontainer.json   # Configuración para VS Code Dev Containers
├── .vscode/
│   ├── settings.json       # Configuraciones de VS Code
│   └── launch.json         # Configuraciones de depuración
├── .gitignore              # Archivos a ignorar en Git
└── README.md               # Este archivo
```

### Configuración del entorno Docker

El entorno incluye:
- **Base**: Ubuntu 22.04 LTS
- **Flutter**: Versión 3.24.4 (stable)
- **Android SDK**: API Level 34
- **Build Tools**: 34.0.0
- **Herramientas adicionales**: ADB, Git, herramientas de compilación

## 📱 Uso con Dispositivos Android

### 1. Preparar el dispositivo Android

1. **Habilita las Opciones de Desarrollador**:
   - Ve a `Configuración` → `Acerca del teléfono`
   - Toca `Número de compilación` 7 veces

2. **Activa la Depuración USB**:
   - Ve a `Configuración` → `Opciones de desarrollador`
   - Activa `Depuración USB`

3. **Conecta el dispositivo** via USB y acepta el diálogo de permisos

### 2. Configuración por sistema operativo

#### En Linux

Para dispositivos Xiaomi/Google (ID 18d1):
```bash
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Para otros fabricantes, identifica el ID del proveedor:
```bash
lsusb
# Busca tu dispositivo y reemplaza 18d1 con el ID correspondiente
```

#### En Windows

1. **Instala los drivers USB** del fabricante de tu dispositivo:
   - **Samsung**: Samsung USB Driver
   - **Xiaomi**: Mi USB Driver
   - **Google**: Google USB Driver
   - **O instala Android Studio** que incluye drivers universales

2. **Verifica que Windows reconoce el dispositivo**:
   - Abre el Administrador de dispositivos
   - Busca tu dispositivo en "Dispositivos portátiles" o "Android Device"

### 3. Configurar ADB

#### En Linux
```bash
# Ubuntu/Debian:
sudo apt install android-tools-adb
# Fedora:
sudo dnf install android-tools
# Arch:
sudo pacman -S android-tools

# Iniciar servidor ADB
adb kill-server
adb start-server
adb devices  # Verificar que el dispositivo aparece
```

#### En Windows
```bash
# Si tienes Android Studio instalado, ADB ya está disponible
# Sino, descarga Platform Tools de Android:
# https://developer.android.com/studio/releases/platform-tools

# Añade ADB al PATH o usa la ruta completa
adb devices  # Verificar que el dispositivo aparece
```

### 4. Ejecutar aplicación en dispositivo

```bash
# Dentro del contenedor
cd tu_proyecto
flutter devices  # Verificar dispositivos disponibles
flutter run       # Ejecutar en dispositivo conectado
```

## 🛠️ Comandos Útiles

### Gestión del contenedor
```bash
# Iniciar el entorno
docker-compose up -d

# Detener el entorno
docker-compose down

# Reconstruir la imagen
docker-compose up -d --build

# Ver logs
docker-compose logs -f

# Acceder al contenedor
docker-compose exec flutter bash
```

### Comandos Flutter
```bash
# Crear nuevo proyecto
flutter create --platforms=android,ios nombre_proyecto

# Ejecutar aplicación
flutter run

# Hot reload (mientras la app está ejecutándose)
# Presiona 'r' en la terminal

# Hot restart (mientras la app está ejecutándose)
# Presiona 'R' en la terminal

# Construir APK
flutter build apk

# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Verificar configuración
flutter doctor -v
```

### Comandos ADB
```bash
# Listar dispositivos
adb devices

# Instalar APK
adb install archivo.apk

# Ver logs del dispositivo
adb logcat

# Reiniciar servidor ADB
adb kill-server && adb start-server
```

## 💻 Desarrollo con VS Code

### Configuración automática con Dev Containers

1. **Abre el proyecto en VS Code**
2. **Instala la extensión Dev Containers** si no la tienes
3. **Abre la paleta de comandos** (F1 o Ctrl+Shift+P)
4. **Ejecuta**: `Dev Containers: Reopen in Container`
5. **Espera** a que VS Code configure el entorno automáticamente

### Extensiones incluidas automáticamente

- Dart
- Flutter
- Flutter Helper
- Flutter Riverpod Snippets
- Awesome Flutter Snippets
- Flutter Intl

### Configuraciones de depuración

El proyecto incluye configuraciones predefinidas para:
- Debug en dispositivo móvil
- Debug en modo web
- Profile mode
- Release mode
- Ejecución de tests

## 🔧 Solución de Problemas

### Dispositivo no detectado

1. **Verifica que el dispositivo aparece en el host**:
   ```bash
   lsusb  # Debe aparecer tu dispositivo
   adb devices  # Debe mostrar tu dispositivo
   ```

2. **Verifica reglas udev**:
   ```bash
   # Verifica que existe la regla
   ls -la /etc/udev/rules.d/51-android.rules
   # Recarga reglas si es necesario
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

3. **Reinicia el contenedor**:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Error "ADB server didn't ACK"

```bash
# En el host
adb kill-server
adb start-server

# Reinicia el contenedor
docker-compose restart
```

### Problemas de permisos

```bash
# Corregir propietario de archivos
sudo chown -R $USER:$USER .

# Verificar que el usuario está en el grupo plugdev (Linux)
groups $USER
```

### VS Code no se conecta al contenedor

1. **Verifica que el contenedor está ejecutándose**:
   ```bash
   docker ps
   ```

2. **Usa "Attach to Running Container" en lugar de "Reopen in Container"**

3. **Verifica que no hay conflictos de puertos**:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

### Performance lenta

1. **Añade exclusiones para mejor rendimiento**:
   - Añade carpetas como `build/`, `.dart_tool/` a tu `.gitignore`
   - Usa volúmenes nombrados para dependencias grandes

2. **En sistemas Windows/macOS, considera usar WSL2 o Docker Desktop con configuración optimizada**

## 🤝 Contribución

1. **Fork el repositorio**
2. **Crea una rama para tu feature**: `git checkout -b feature/nueva-caracteristica`
3. **Commit tus cambios**: `git commit -am 'Añade nueva característica'`
4. **Push a la rama**: `git push origin feature/nueva-caracteristica`
5. **Crea un Pull Request**

## 📝 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🙋‍♂️ Soporte

Si tienes problemas o preguntas:

1. **Revisa la sección de [Solución de Problemas](#solución-de-problemas)**
2. **Busca en los [Issues existentes](../../issues)**
3. **Crea un nuevo Issue** con detalles sobre tu problema

## 📚 Recursos Adicionales

- [Documentación oficial de Flutter](https://flutter.dev/docs)
- [Documentación de Docker](https://docs.docker.com/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/remote/containers)
- [Android Debug Bridge (ADB)](https://developer.android.com/studio/command-line/adb)

---

**¡Happy Coding! 🎉**
