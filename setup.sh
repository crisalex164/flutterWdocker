#!/bin/bash

# Script de configuración automática para Flutter Docker Development Environment
# Plataforma: Linux
# Versión: 1.0

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes coloreados
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║             Flutter Docker Development Environment             ║"
echo "║                    Configuración Automática                   ║"
echo "║                           Linux                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verificar si estamos en Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "Este script está diseñado para Linux."
    print_error "Para Windows, usa setup.bat"
    print_error "Para macOS, usa setup.sh pero ten en cuenta que algunas funciones pueden no estar disponibles."
    exit 1
fi

print_status "Verificando dependencias..."

# Verificar Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor, instala Docker primero."
    echo "Visita: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose no está instalado. Por favor, instala Docker Compose primero."
    echo "Visita: https://docs.docker.com/compose/install/"
    exit 1
fi

print_success "Docker y Docker Compose están instalados"

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    print_error "Docker no está ejecutándose. Por favor, inicia Docker primero."
    exit 1
fi

print_success "Docker está ejecutándose correctamente"

# Detectar dispositivos Android conectados
print_status "Detectando dispositivos Android..."

if command -v lsusb &> /dev/null; then
    # Buscar dispositivos Android comunes
    android_devices=$(lsusb | grep -E "(Google|Samsung|Xiaomi|Huawei|OnePlus|LG|Motorola|Sony)" || true)
    
    if [ ! -z "$android_devices" ]; then
        print_success "Dispositivos Android detectados:"
        echo "$android_devices"
        
        # Extraer vendor IDs
        vendor_ids=$(echo "$android_devices" | grep -oE "ID [0-9a-f]{4}:" | cut -d' ' -f2 | cut -d':' -f1 | sort -u)
        
        print_status "Configurando reglas udev para dispositivos detectados..."
        
        for vendor_id in $vendor_ids; do
            udev_rule="SUBSYSTEM==\"usb\", ATTR{idVendor}==\"$vendor_id\", MODE=\"0666\", GROUP=\"plugdev\""
            echo "$udev_rule" | sudo tee "/etc/udev/rules.d/51-android-$vendor_id.rules" > /dev/null
            print_success "Regla udev creada para vendor ID: $vendor_id"
        done
        
        # Recargar reglas udev
        sudo chmod -R a+r /etc/udev/rules.d/51-android-*.rules
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        print_success "Reglas udev aplicadas"
    else
        print_warning "No se detectaron dispositivos Android. Puedes configurar las reglas udev manualmente más tarde."
    fi
else
    print_warning "lsusb no está disponible. Omitiendo detección automática de dispositivos."
fi

# Instalar ADB si no está instalado
print_status "Verificando instalación de ADB..."

if ! command -v adb &> /dev/null; then
    print_status "ADB no está instalado. Intentando instalarlo..."
    
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y android-tools-adb
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y android-tools
    elif command -v pacman &> /dev/null; then
        sudo pacman -S android-tools
    elif command -v zypper &> /dev/null; then
        sudo zypper install android-tools
    else
        print_warning "No se pudo instalar ADB automáticamente. Por favor, instálalo manualmente."
    fi
    
    if command -v adb &> /dev/null; then
        print_success "ADB instalado correctamente"
    else
        print_warning "No se pudo verificar la instalación de ADB"
    fi
else
    print_success "ADB ya está instalado"
fi

# Añadir usuario al grupo plugdev si existe
if getent group plugdev > /dev/null 2>&1; then
    if ! groups $USER | grep -q plugdev; then
        print_status "Añadiendo usuario al grupo plugdev..."
        sudo usermod -a -G plugdev $USER
        print_success "Usuario añadido al grupo plugdev. Necesitarás cerrar sesión y volver a entrar para que surta efecto."
    else
        print_success "Usuario ya está en el grupo plugdev"
    fi
fi

# Construir el entorno Docker
print_status "Construyendo el entorno Docker (esto puede tardar varios minutos)..."

if docker-compose build; then
    print_success "Imagen Docker construida correctamente"
else
    print_error "Error al construir la imagen Docker"
    exit 1
fi

# Iniciar el contenedor
print_status "Iniciando el contenedor..."

if docker-compose up -d; then
    print_success "Contenedor iniciado correctamente"
else
    print_error "Error al iniciar el contenedor"
    exit 1
fi

# Verificar que Flutter está funcionando
print_status "Verificando instalación de Flutter..."

if docker-compose exec -T flutter flutter --version; then
    print_success "Flutter está funcionando correctamente"
else
    print_error "Error al verificar Flutter"
    docker-compose down
    exit 1
fi

# Verificar flutter doctor
print_status "Ejecutando flutter doctor..."
docker-compose exec -T flutter flutter doctor

# Mostrar dispositivos conectados
print_status "Verificando dispositivos conectados..."

if command -v adb &> /dev/null; then
    adb kill-server > /dev/null 2>&1 || true
    adb start-server > /dev/null 2>&1 || true
    echo "Dispositivos ADB en el host:"
    adb devices
fi

echo
echo "Dispositivos detectados por Flutter:"
docker-compose exec -T flutter flutter devices

# Mensaje final
echo
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    🎉 ¡Configuración Completa! 🎉            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo "Tu entorno de desarrollo Flutter con Docker está listo para usar."
echo
echo "Próximos pasos:"
echo "1. Para conectarte al contenedor: docker-compose exec flutter bash"
echo "2. Para crear un nuevo proyecto: flutter create mi_app"
echo "3. Para abrir en VS Code: Abre este directorio en VS Code y usa 'Reopen in Container'"
echo
echo "Si tienes dispositivos Android conectados, asegúrate de:"
echo "- Tener la depuración USB habilitada"
echo "- Aceptar el diálogo de permisos en el dispositivo"
echo "- Reiniciar la sesión si se te añadió al grupo plugdev"
echo
echo "Para más información, consulta el README.md"
echo
print_success "¡Happy coding! 🚀"
