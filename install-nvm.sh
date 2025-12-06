#!/bin/bash

set -e

echo "📦 Instalando NVM y versiones de Node.js..."

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# Verificar si NVM ya está instalado
if [ -d "$HOME/.nvm" ]; then
    print_step "NVM ya está instalado. Actualizando..."
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Actualizar NVM
    (
        cd "$NVM_DIR"
        git fetch --tags origin
        git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    ) && \. "$NVM_DIR/nvm.sh"
    print_success "NVM actualizado"
else
    print_step "Instalando NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Cargar NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    print_success "NVM instalado"
fi

# Verificar que NVM está cargado
if ! command -v nvm &> /dev/null; then
    # Intentar cargar desde los archivos de configuración
    if [ -f "$HOME/.bashrc" ]; then
        source "$HOME/.bashrc"
    fi
    if [ -f "$HOME/.zshrc" ]; then
        source "$HOME/.zshrc"
    fi
fi

# Versiones de Node.js a instalar
NODE_VERSIONS=(14 16 18 20 22)

print_step "Instalando versiones de Node.js: ${NODE_VERSIONS[*]}..."

for version in "${NODE_VERSIONS[@]}"; do
    print_step "Instalando Node.js v$version..."
    nvm install "$version" || {
        echo "⚠️  Error instalando Node.js v$version, continuando..."
    }
    print_success "Node.js v$version instalado"
done

# Establecer Node.js 22 como versión por defecto
print_step "Estableciendo Node.js 22 como versión por defecto..."
nvm alias default 22
nvm use default

print_success "Node.js 22 configurado como versión por defecto"

# Mostrar información
echo ""
echo -e "${GREEN}✅ Instalación completada!${NC}"
echo ""
echo "📊 Versiones instaladas:"
nvm list
echo ""
echo "💡 Para usar una versión específica: nvm use <versión>"
echo "💡 Versión actual: $(node --version)"
echo ""

