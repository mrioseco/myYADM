#!/bin/bash

set -e

echo "🚀 Iniciando configuración de My YADM..."
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Verificar que estamos en el directorio home y que los archivos del repo existen
# Esto es más permisivo - verifica que los archivos están presentes en lugar de
# la estructura interna de YADM (que puede no estar completamente inicializada)
if [ -f "$HOME/setup.sh" ] || [ -f "$HOME/README.md" ]; then
    print_success "Archivos del repositorio detectados en $HOME"
else
    print_warning "No se encontraron los archivos del repositorio en $HOME"
    print_warning "Asegúrate de:"
    print_warning "  1. Estar en el directorio home: cd \$HOME"
    print_warning "  2. Haber clonado el repo: yadm clone <URL>"
    print_warning ""
    print_warning "Continuando de todas formas (puede ser primera configuración)..."
    echo ""
fi

print_step "Verificando dependencias del sistema..."

# Detectar el sistema operativo
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    print_warning "No se pudo detectar el sistema operativo. Continuando..."
    OS="unknown"
fi

# Instalar dependencias básicas según el OS
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    print_step "Actualizando lista de paquetes..."
    sudo apt-get update -qq
    
    print_step "Instalando dependencias básicas..."
    sudo apt-get install -y \
        curl \
        wget \
        git \
        build-essential \
        ca-certificates \
        gnupg \
        lsb-release
    
    print_success "Dependencias básicas instaladas"
elif [ "$OS" = "fedora" ] || [ "$OS" = "rhel" ]; then
    print_step "Instalando dependencias básicas..."
    sudo dnf install -y \
        curl \
        wget \
        git \
        gcc \
        gcc-c++ \
        make \
        ca-certificates
    print_success "Dependencias básicas instaladas"
fi

# Instalar YADM si no está instalado
if ! command -v yadm &> /dev/null; then
    print_step "Instalando YADM..."
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        sudo apt-get install -y yadm
    elif [ "$OS" = "fedora" ] || [ "$OS" = "rhel" ]; then
        sudo dnf install -y yadm
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install yadm
        else
            print_warning "Homebrew no está instalado. Por favor instala YADM manualmente."
        fi
    fi
    print_success "YADM instalado"
else
    print_success "YADM ya está instalado"
fi

# Instalar NVM y Node.js
print_step "Instalando NVM y versiones de Node.js..."
if [ -f "$HOME/install-nvm.sh" ]; then
    chmod +x "$HOME/install-nvm.sh"
    bash "$HOME/install-nvm.sh"
    print_success "NVM y Node.js instalados"
else
    print_warning "No se encontró install-nvm.sh. Instalando NVM manualmente..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Instalar versiones de Node
    nvm install 14
    nvm install 16
    nvm install 18
    nvm install 20
    nvm install 22
    nvm alias default 22
    print_success "NVM y Node.js instalados"
fi

# Instalar Cursor
print_step "Instalando Cursor..."
if ! command -v cursor &> /dev/null; then
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        CURSOR_DIR="$HOME/.local/bin"
        mkdir -p "$CURSOR_DIR"
        
        # Intentar múltiples métodos de instalación
        CURSOR_INSTALLED=false
        
        # Método 1: Descargar AppImage desde la URL oficial
        print_step "Intentando descargar Cursor AppImage..."
        CURSOR_DOWNLOAD_URL="https://downloader.cursor.sh/linux/appImage/x64"
        
        if curl -L --connect-timeout 10 --max-time 60 "$CURSOR_DOWNLOAD_URL" -o "$CURSOR_DIR/cursor" 2>/dev/null; then
            chmod +x "$CURSOR_DIR/cursor"
            CURSOR_INSTALLED=true
            print_success "Cursor descargado e instalado desde AppImage"
        else
            print_warning "No se pudo descargar Cursor desde la URL oficial"
            
            # Método 2: Intentar con wget como alternativa
            print_step "Intentando con wget como alternativa..."
            if command -v wget &> /dev/null; then
                if wget --timeout=10 --tries=3 -O "$CURSOR_DIR/cursor" "$CURSOR_DOWNLOAD_URL" 2>/dev/null; then
                    chmod +x "$CURSOR_DIR/cursor"
                    CURSOR_INSTALLED=true
                    print_success "Cursor descargado e instalado con wget"
                fi
            fi
        fi
        
        # Método 3: Intentar con el script de instalación oficial (si los métodos anteriores fallaron)
        if [ "$CURSOR_INSTALLED" = false ]; then
            print_step "Intentando con el script de instalación oficial de Cursor..."
            if command -v wget &> /dev/null; then
                # Script de instalación oficial de Cursor
                if wget -qO - https://download.todesktop.com/210303leazlircz/linux 2>/dev/null | sh; then
                    CURSOR_INSTALLED=true
                    print_success "Cursor instalado con el script oficial"
                fi
            fi
        fi
        
        # Si aún no se instaló, ofrecer instrucciones manuales
        if [ "$CURSOR_INSTALLED" = false ]; then
            print_warning "No se pudo instalar Cursor automáticamente."
            print_warning "Por favor instálalo manualmente:"
            echo ""
            echo "  Opción 1 - Script oficial:"
            echo "    wget -qO - https://download.todesktop.com/210303leazlircz/linux | sh"
            echo ""
            echo "  Opción 2 - Descargar manualmente:"
            echo "    1. Visita https://cursor.sh/download"
            echo "    2. Descarga el .deb o AppImage para Linux"
            echo "    3. Instala según el formato descargado"
            echo ""
            print_warning "Después de instalar Cursor manualmente, puedes continuar con el resto de la configuración."
        else
            # Agregar al PATH si no está
            if [[ ":$PATH:" != *":$CURSOR_DIR:"* ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
                export PATH="$HOME/.local/bin:$PATH"
            fi
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew install --cask cursor
        else
            print_warning "Homebrew no está instalado. Por favor instala Cursor manualmente desde https://cursor.sh"
        fi
    else
        print_warning "Sistema operativo no soportado para instalación automática de Cursor."
        print_warning "Por favor instala Cursor manualmente desde https://cursor.sh"
    fi
else
    print_success "Cursor ya está instalado"
fi

# Instalar i3 Window Manager y dependencias
print_step "Instalando i3 Window Manager y dependencias..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    # Verificar si i3 ya está instalado
    if ! command -v i3 &> /dev/null; then
        print_step "Instalando i3 y dependencias..."
        sudo apt-get install -y \
            i3 \
            i3status \
            i3lock \
            dmenu \
            dex \
            network-manager-gnome \
            xss-lock \
            scrot \
            xclip \
            pulseaudio \
            pavucontrol \
            shutter
        
        print_success "i3 y dependencias instaladas"
        
        # Crear directorio para screenshots si no existe
        mkdir -p "$HOME/Pictures/screenshots"
        
        print_warning "⚠️  IMPORTANTE: i3 ha sido instalado."
        print_warning "   Debes cerrar sesión y seleccionar 'i3' como gestor de ventanas"
        print_warning "   al iniciar sesión nuevamente."
        print_warning "   Después de iniciar sesión con i3, puedes continuar con la configuración."
    else
        print_success "i3 ya está instalado"
    fi
    
    # Verificar que la configuración de i3 existe
    if [ -f "$HOME/.config/i3/config" ]; then
        print_success "Configuración de i3 encontrada"
    else
        print_warning "No se encontró configuración de i3 en ~/.config/i3/config"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    print_warning "i3 no está disponible en macOS. Se omite la instalación."
else
    print_warning "Sistema operativo no soportado para instalación automática de i3."
    print_warning "Por favor instala i3 manualmente según tu distribución."
fi

# Configurar shell aliases
print_step "Configurando shell aliases..."
if [ -f "$HOME/.shell_aliases" ]; then
    # Verificar si ya está en .bashrc o .zshrc
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q ".shell_aliases" "$HOME/.bashrc"; then
            echo "" >> "$HOME/.bashrc"
            echo "# Cargar aliases personalizados" >> "$HOME/.bashrc"
            echo "[ -f ~/.shell_aliases ] && source ~/.shell_aliases" >> "$HOME/.bashrc"
            print_success "Aliases agregados a .bashrc"
        else
            print_success "Aliases ya configurados en .bashrc"
        fi
    fi
    
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q ".shell_aliases" "$HOME/.zshrc"; then
            echo "" >> "$HOME/.zshrc"
            echo "# Cargar aliases personalizados" >> "$HOME/.zshrc"
            echo "[ -f ~/.shell_aliases ] && source ~/.shell_aliases" >> "$HOME/.zshrc"
            print_success "Aliases agregados a .zshrc"
        else
            print_success "Aliases ya configurados en .zshrc"
        fi
    fi
else
    print_warning "No se encontró .shell_aliases"
fi

# Hacer scripts ejecutables
print_step "Configurando permisos de scripts..."
if [ -d "$HOME/scripts" ]; then
    chmod +x "$HOME/scripts"/*.sh 2>/dev/null || true
    print_success "Scripts en ~/scripts configurados"
fi

if [ -d "$HOME/bin" ]; then
    chmod +x "$HOME/bin"/*.sh 2>/dev/null || true
    print_success "Scripts en ~/bin configurados"
fi

echo ""
echo -e "${GREEN}✅ Configuración completada exitosamente!${NC}"
echo ""
echo "📝 Próximos pasos:"
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    if command -v i3 &> /dev/null && [ ! -f "$HOME/.i3-setup-complete" ]; then
        echo -e "${YELLOW}⚠️  IMPORTANTE - Configuración de i3:${NC}"
        echo "   1. Cierra sesión completamente"
        echo "   2. En la pantalla de login, selecciona 'i3' como gestor de ventanas"
        echo "      (normalmente hay un icono de engranaje o menú para seleccionar)"
        echo "   3. Inicia sesión con i3"
        echo "   4. Una vez en i3, ejecuta: touch ~/.i3-setup-complete"
        echo ""
    fi
fi
echo "   1. Cierra y abre una nueva terminal para que los cambios surtan efecto"
echo "   2. Verifica que todo funciona:"
echo "      - cursor --version"
echo "      - nvm --version"
echo "      - node --version"
if command -v i3 &> /dev/null; then
    echo "      - i3 --version"
fi
echo ""
echo "💡 Tip: Usa 'yadm status' para ver el estado de tus configuraciones"
echo "💡 Tip: En i3, presiona Mod+Shift+c para recargar la configuración"
echo ""

