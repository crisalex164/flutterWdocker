# 📱 Configuración de Dispositivos Android

Esta guía te ayudará a configurar correctamente tu dispositivo Android para desarrollo con Flutter en Docker.

## 🔧 Configuración General del Dispositivo

### 1. Habilitar Opciones de Desarrollador

1. Ve a **Configuración** → **Acerca del teléfono**
2. Busca **Número de compilación** (puede estar en "Información del software")
3. Toca **7 veces** seguidas hasta ver el mensaje "Ahora eres desarrollador"

### 2. Activar Depuración USB

1. Ve a **Configuración** → **Opciones de desarrollador**
2. Activa **Depuración USB**
3. Activa **Instalación vía USB** (si está disponible)
4. Activa **Verificación de aplicaciones vía USB** (recomendado)

### 3. Configuración de USB

En **Opciones de desarrollador**, también puedes configurar:
- **Configuración USB por defecto**: Selecciona "Transferencia de archivos" o "PTP"
- **Revocar autorizaciones de depuración USB**: Útil si tienes problemas de permisos

## 🏭 Configuración por Fabricante

### Xiaomi (MIUI)

**Pasos adicionales:**
1. Ve a **Configuración** → **Opciones de desarrollador**
2. Activa **Depuración USB (Modo de seguridad)**
3. Activa **Instalar vía USB**
4. Si aparece, activa **Depuración USB de aplicaciones del sistema**

**Problemas comunes:**
- Algunas versiones de MIUI requieren cuenta Mi para depuración
- En algunos casos necesitas "Desbloquear OEM" activado

### Samsung (One UI)

**Pasos adicionales:**
1. En **Opciones de desarrollador**:
   - Activa **Depuración USB**
   - Activa **Instalar aplicaciones desconocidas vía USB**
2. Puede aparecer un aviso de Knox - acepta para desarrollo

**Drivers Windows:**
- Instala Samsung Smart Switch (incluye drivers USB)
- O descarga Samsung USB Driver por separado

### Google Pixel

**Configuración estándar:**
- Sigue los pasos generales
- No requiere configuración adicional
- Drivers incluidos automáticamente en Windows 10/11

### OnePlus (OxygenOS)

**Pasos adicionales:**
1. En **Opciones de desarrollador**:
   - Activa **Depuración USB**
   - Activa **Desbloqueo OEM** (si planeas desarrollo avanzado)

### Huawei (EMUI)

**Nota importante:**
- Dispositivos nuevos sin Google Play Services pueden tener limitaciones
- Para dispositivos con EMUI 10+, verifica compatibilidad

## 💻 Configuración del Host por SO

### Linux

#### Identificar dispositivo
```bash
# Conecta el dispositivo y ejecuta:
lsusb

# Busca una línea como:
# Bus 003 Device 014: ID 18d1:4ee7 Google Inc. Pixel
#                       ^^^^
#                   Vendor ID
```

#### Crear regla udev
```bash
# Para Xiaomi/Google (18d1):
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules

# Para Samsung (04e8):
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules

# Para OnePlus (2a70):
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2a70", MODE="0666", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/51-android.rules

# Aplicar cambios:
sudo chmod a+r /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

#### Añadir usuario a grupo plugdev
```bash
sudo usermod -a -G plugdev $USER
# Cerrar sesión y volver a entrar
```

### Windows

#### Instalar drivers USB

**Opción 1: Android Studio (recomendado)**
- Instala Android Studio
- Los drivers se instalan automáticamente

**Opción 2: Drivers específicos del fabricante**
- **Xiaomi**: Mi USB Driver
- **Samsung**: Samsung Smart Switch o Samsung USB Driver
- **Google**: Google USB Driver
- **OnePlus**: OnePlus USB Drivers

**Opción 3: Universal ADB Driver**
- Para dispositivos no reconocidos
- Búscalo en internet como "Universal ADB Driver"

#### Verificar instalación
1. Abre **Administrador de dispositivos**
2. Conecta tu dispositivo
3. Busca en **Dispositivos portátiles** o **Android Device**
4. Si aparece con signo de exclamación, actualiza el driver

## ✅ Verificación de Configuración

### Test básico
```bash
# En el host (Linux/Windows):
adb devices
```

**Salida esperada:**
```
List of devices attached
ABC123DEF456    device
```

### Test desde contenedor Docker
```bash
# Conectar al contenedor:
docker-compose exec flutter bash

# Dentro del contenedor:
adb devices
flutter devices
```

### Test de instalación
```bash
# Crear proyecto de prueba:
flutter create test_app
cd test_app

# Ejecutar en dispositivo:
flutter run
```

## 🔧 Solución de Problemas Específicos

### "device unauthorized"
1. Revoca autorizaciones en el dispositivo
2. Desconecta y reconecta el USB
3. Acepta el diálogo de autorización marcando "Siempre permitir"

### "device offline"  
```bash
adb kill-server
adb start-server
```

### "no permissions"
- **Linux**: Verifica reglas udev y grupo plugdev
- **Windows**: Reinstala drivers USB

### Dispositivo detectado pero Flutter no lo ve
```bash
# Reinicia el servidor ADB:
adb kill-server
adb start-server

# Reinicia Flutter:
flutter clean
flutter doctor
```

## 📋 Checklist de Configuración

### ✅ En el dispositivo:
- [ ] Opciones de desarrollador habilitadas
- [ ] Depuración USB activada  
- [ ] Instalación vía USB activada
- [ ] Cable USB de datos (no solo carga)

### ✅ En el host:
- [ ] ADB instalado y funcionando
- [ ] Drivers USB correctos (Windows)
- [ ] Reglas udev configuradas (Linux)
- [ ] Usuario en grupo plugdev (Linux)

### ✅ En el contenedor:
- [ ] ADB detecta el dispositivo
- [ ] Flutter detecta el dispositivo
- [ ] Proyecto de prueba se ejecuta correctamente

## 🆘 ¿Problemas?

Si sigues teniendo problemas después de seguir esta guía:

1. Consulta [troubleshooting.md](troubleshooting.md)
2. Verifica que tienes la última versión de este repositorio
3. Pregunta al equipo en el canal de desarrollo
4. Crea un issue con los detalles específicos de tu configuración
