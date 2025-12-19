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

# Instalar dependencias básicas según el OS (solo las que faltan)
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    print_step "Verificando dependencias básicas..."
    
    # Lista de paquetes necesarios
    PACKAGES="curl wget git build-essential ca-certificates gnupg lsb-release unzip jq"
    MISSING_PACKAGES=""
    
    # Verificar qué paquetes faltan
    for pkg in $PACKAGES; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
        fi
    done
    
    if [ -n "$MISSING_PACKAGES" ]; then
        print_step "Actualizando lista de paquetes..."
        sudo apt-get update -qq
        
        print_step "Instalando dependencias faltantes:$MISSING_PACKAGES"
        sudo apt-get install -y $MISSING_PACKAGES
        print_success "Dependencias básicas instaladas"
    else
        print_success "Todas las dependencias básicas ya están instaladas"
    fi
elif [ "$OS" = "fedora" ] || [ "$OS" = "rhel" ]; then
    print_step "Verificando dependencias básicas..."
    
    # Lista de paquetes necesarios
    PACKAGES="curl wget git gcc gcc-c++ make ca-certificates unzip jq"
    MISSING_PACKAGES=""
    
    # Verificar qué paquetes faltan
    for pkg in $PACKAGES; do
        if ! rpm -q "$pkg" &>/dev/null; then
            MISSING_PACKAGES="$MISSING_PACKAGES $pkg"
        fi
    done
    
    if [ -n "$MISSING_PACKAGES" ]; then
        print_step "Instalando dependencias faltantes:$MISSING_PACKAGES"
        sudo dnf install -y $MISSING_PACKAGES
        print_success "Dependencias básicas instaladas"
    else
        print_success "Todas las dependencias básicas ya están instaladas"
    fi
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

# Instalar NVM y Node.js (solo si no están instalados)
print_step "Verificando NVM y Node.js..."

# Cargar NVM si existe
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
fi

# Verificar si NVM está instalado (verificando si el directorio y el script existen)
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    print_step "Instalando NVM..."
    if [ -f "$HOME/install-nvm.sh" ]; then
        chmod +x "$HOME/install-nvm.sh"
        bash "$HOME/install-nvm.sh"
    else
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    print_success "NVM instalado"
else
    print_success "NVM ya está instalado"
    # Asegurar que NVM está cargado
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Instalar versiones de Node solo si no están instaladas
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
    
    NODE_VERSIONS="14 16 18 20 22"
    for version in $NODE_VERSIONS; do
        # Verificar si la versión está instalada usando nvm list
        if ! nvm list "$version" 2>/dev/null | grep -q "v$version\."; then
            print_step "Instalando Node.js v$version..."
            nvm install "$version" >/dev/null 2>&1
        else
            print_success "Node.js v$version ya está instalado"
        fi
    done
    
    # Configurar versión por defecto solo si no está configurada
    CURRENT_DEFAULT=$(nvm alias default 2>/dev/null | grep -oE "v[0-9]+" | head -1 || echo "")
    if [ -z "$CURRENT_DEFAULT" ] || [ "$CURRENT_DEFAULT" != "v22" ]; then
        # Verificar que v22 existe antes de configurarlo como default
        if nvm list 22 2>/dev/null | grep -q "v22\."; then
            print_step "Configurando Node.js v22 como versión por defecto..."
            nvm alias default 22 >/dev/null 2>&1 || true
        fi
    else
        print_success "Node.js v22 ya está configurado como versión por defecto"
    fi
    print_success "Verificación de Node.js completada"
fi

# Instalar ntl (solo si no está instalado)
print_step "Verificando ntl..."
if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
    
    # Usar Node.js por defecto
    nvm use default >/dev/null 2>&1 || true
    
    # Verificar si ntl está instalado
    if ! command -v ntl &> /dev/null; then
        print_step "Instalando ntl..."
        npm install -g ntl >/dev/null 2>&1
        print_success "ntl instalado"
    else
        print_success "ntl ya está instalado"
    fi
else
    print_warning "NVM no está disponible. ntl requiere Node.js instalado."
fi

# Nota sobre Cursor - debe instalarse manualmente
print_step "Verificando Cursor..."
if ! command -v cursor &> /dev/null; then
    print_warning "⚠️  Cursor no está instalado."
    print_warning "   Cursor debe instalarse manualmente desde https://cursor.sh/download"
    print_warning "   Descarga la última versión disponible e instálala según las instrucciones del sitio."
    echo ""
else
    print_success "Cursor ya está instalado"
fi

# Instalar AWS CLI (solo si no está instalado)
print_step "Verificando AWS CLI..."
if ! command -v aws &> /dev/null; then
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ] || [ "$OS" = "fedora" ] || [ "$OS" = "rhel" ]; then
        print_step "Descargando AWS CLI..."
        AWS_CLI_DIR="$HOME/.local/aws-cli"
        mkdir -p "$AWS_CLI_DIR"
        
        # Descargar el instalador de AWS CLI v2
        AWS_CLI_INSTALLER="/tmp/awscli-installer.zip"
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$AWS_CLI_INSTALLER"
        
        # Instalar AWS CLI
        unzip -q "$AWS_CLI_INSTALLER" -d /tmp
        /tmp/aws/install -i "$AWS_CLI_DIR" -b "$HOME/.local/bin"
        
        # Limpiar archivos temporales
        rm -rf "$AWS_CLI_INSTALLER" /tmp/aws
        
        # Agregar al PATH si no está
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            export PATH="$HOME/.local/bin:$PATH"
        fi
        
        print_success "AWS CLI instalado"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            if ! brew list awscli &>/dev/null; then
                print_step "Instalando AWS CLI..."
                brew install awscli
                print_success "AWS CLI instalado"
            else
                print_success "AWS CLI ya está instalado"
            fi
        else
            print_warning "Homebrew no está instalado. Por favor instala AWS CLI manualmente:"
            echo "  curl 'https://awscli.amazonaws.com/AWSCLIV2.pkg' -o /tmp/AWSCLIV2.pkg"
            echo "  sudo installer -pkg /tmp/AWSCLIV2.pkg -target /"
        fi
    else
        print_warning "Sistema operativo no soportado para instalación automática de AWS CLI."
        print_warning "Por favor instala AWS CLI manualmente desde https://aws.amazon.com/cli/"
    fi
else
    print_success "AWS CLI ya está instalado"
fi

# Instalar Slack (solo si no está instalado)
print_step "Verificando Slack..."
if ! command -v slack &> /dev/null; then
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        # Intentar instalar con snap primero (más fácil de mantener)
        if command -v snap &> /dev/null; then
            print_step "Instalando Slack con snap..."
            sudo snap install slack --classic
            print_success "Slack instalado"
        else
            # Si snap no está disponible, descargar e instalar .deb
            print_step "Instalando snapd para Slack..."
            sudo apt-get install -y snapd
            sudo snap install slack --classic
            print_success "Slack instalado"
        fi
    elif [ "$OS" = "fedora" ] || [ "$OS" = "rhel" ]; then
        # Intentar instalar con snap primero
        if command -v snap &> /dev/null; then
            print_step "Instalando Slack con snap..."
            sudo snap install slack --classic
            print_success "Slack instalado"
        else
            print_warning "snap no está disponible. Por favor instala Slack manualmente:"
            echo "  sudo dnf install -y snapd"
            echo "  sudo snap install slack --classic"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            if ! brew list --cask slack &>/dev/null; then
                print_step "Instalando Slack..."
                brew install --cask slack
                print_success "Slack instalado"
            else
                print_success "Slack ya está instalado"
            fi
        else
            print_warning "Homebrew no está instalado. Por favor instala Slack manualmente desde https://slack.com/downloads"
        fi
    else
        print_warning "Sistema operativo no soportado para instalación automática de Slack."
        print_warning "Por favor instala Slack manualmente desde https://slack.com/downloads"
    fi
else
    print_success "Slack ya está instalado"
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
            shutter \
            imagemagick
        
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
echo "      - aws --version"
echo "      - nvm --version"
echo "      - node --version"
echo "      - npm --version"
echo "      - ntl --version"
echo "      - slack --version"
echo "   3. Configura AWS CLI con tus credenciales:"
echo "      - aws configure"
if command -v i3 &> /dev/null; then
    echo "      - i3 --version"
fi
echo ""
echo "💡 Tip: Usa 'yadm status' para ver el estado de tus configuraciones"
echo "💡 Tip: En i3, presiona Mod+Shift+c para recargar la configuración"
echo ""

