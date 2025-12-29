#!/bin/bash

# Script para solucionar problemas de credenciales de Git con VS Code/Cursor

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "🔧 Solucionando problemas de credenciales de Git..."
echo ""

# 1. Deshabilitar helpers globales que puedan interferir
print_step "Limpiando helpers globales conflictivos..."
git config --global --unset-all credential.helper 2>/dev/null || true
print_success "Helpers globales limpiados"

# 2. Asegurar que los helpers específicos por URL estén configurados
print_step "Verificando helpers específicos por URL..."

# CodeCommit
if command -v aws &> /dev/null && [ -f "$HOME/.aws/credentials" ]; then
    git config --global credential.https://git-codecommit.*.amazonaws.com.helper '!aws codecommit credential-helper $@'
    git config --global credential.https://git-codecommit.*.amazonaws.com.UseHttpPath true
    print_success "Helper de CodeCommit configurado"
fi

# GitHub
git config --global credential.https://github.com.helper store
print_success "Helper de GitHub configurado (store)"

# GitLab
git config --global credential.https://gitlab.com.helper store
print_success "Helper de GitLab configurado (store)"

# 3. Deshabilitar helper de VS Code/Cursor
print_step "Deshabilitando helper de VS Code/Cursor..."

# Para VS Code
if [ -f "$HOME/.config/Code/User/settings.json" ]; then
    # Verificar si ya tiene la configuración
    if ! grep -q '"git.useIntegratedAskPass"' "$HOME/.config/Code/User/settings.json"; then
        # Agregar configuración para deshabilitar el helper de VS Code
        # Esto requiere editar el JSON manualmente, así que solo mostramos la instrucción
        print_warning "Necesitas agregar estas líneas a ~/.config/Code/User/settings.json:"
        echo '  "git.useIntegratedAskPass": false,'
        echo '  "git.terminalAuthentication": false'
    else
        print_success "Configuración de VS Code ya está presente"
    fi
fi

# Para Cursor (mismo directorio que VS Code)
if [ -f "$HOME/.config/Cursor/User/settings.json" ]; then
    if ! grep -q '"git.useIntegratedAskPass"' "$HOME/.config/Cursor/User/settings.json"; then
        print_warning "Necesitas agregar estas líneas a ~/.config/Cursor/User/settings.json:"
        echo '  "git.useIntegratedAskPass": false,'
        echo '  "git.terminalAuthentication": false'
    else
        print_success "Configuración de Cursor ya está presente"
    fi
fi

# 4. Verificar .git-credentials
print_step "Verificando archivo de credenciales..."
if [ -f "$HOME/.git-credentials" ]; then
    chmod 600 "$HOME/.git-credentials"
    print_success "Permisos de .git-credentials corregidos (600)"
    
    # Mostrar qué servidores tienen credenciales guardadas
    echo ""
    echo "Credenciales guardadas para:"
    grep -oP 'https://[^:]+' "$HOME/.git-credentials" | sed 's|https://||' | sed 's|@.*||' | sort -u | while read server; do
        echo "  - $server"
    done
else
    print_warning "No se encontró ~/.git-credentials"
fi

# 5. Mostrar configuración actual
echo ""
print_step "Configuración actual de Git:"
git config --global --get-regexp credential | grep -v "^credential\.usehttppath" || echo "  (ninguna configuración global)"

echo ""
echo -e "${GREEN}✅ Correcciones aplicadas!${NC}"
echo ""
echo "Próximos pasos:"
echo "1. Si usas VS Code/Cursor, reinícialo para que los cambios surtan efecto"
echo "2. Si el problema persiste, prueba hacer git push desde la terminal (fuera de VS Code)"
echo "3. Si necesitas reconfigurar GitHub, ejecuta: ~/scripts/setup-github-token.sh"
echo ""
echo "Para verificar que funciona:"
echo "  git config --global --get-regexp credential"

