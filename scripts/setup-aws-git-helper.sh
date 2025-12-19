#!/bin/bash

# Script para configurar Git Credential Helper de AWS CodeCommit
# Prerequisito: AWS CLI debe estar instalado y configurado (aws configure)

set -e

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}✗${NC} $1"
}

echo "🔐 Configurando Git Credential Helper para AWS CodeCommit..."
echo ""

# Verificar que AWS CLI está instalado
print_step "Verificando AWS CLI..."
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI no está instalado."
    echo ""
    echo "Por favor instala AWS CLI primero:"
    echo "  - Ejecuta el setup.sh principal, o"
    echo "  - Instala manualmente desde https://aws.amazon.com/cli/"
    exit 1
fi
print_success "AWS CLI está instalado"

# Verificar que AWS CLI está configurado
print_step "Verificando configuración de AWS CLI..."
if [ ! -f "$HOME/.aws/credentials" ] || [ ! -f "$HOME/.aws/config" ]; then
    print_error "AWS CLI no está configurado."
    echo ""
    echo "Por favor configura AWS CLI primero ejecutando:"
    echo "  aws configure"
    echo ""
    echo "Esto te pedirá:"
    echo "  - AWS Access Key ID"
    echo "  - AWS Secret Access Key"
    echo "  - Default region (normalmente us-east-1)"
    echo "  - Default output format (puedes dejar json)"
    exit 1
fi

# Verificar que las credenciales no estén vacías
if ! grep -q "\[default\]" "$HOME/.aws/credentials" || \
   ! grep -q "aws_access_key_id" "$HOME/.aws/credentials" || \
   ! grep -q "aws_secret_access_key" "$HOME/.aws/credentials"; then
    print_error "Las credenciales de AWS no están configuradas correctamente."
    echo ""
    echo "Por favor ejecuta: aws configure"
    exit 1
fi
print_success "AWS CLI está configurado correctamente"

# Verificar que Git está instalado
print_step "Verificando Git..."
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado."
    echo ""
    echo "Por favor instala Git primero."
    exit 1
fi
print_success "Git está instalado"

# Verificar si el helper ya está configurado
print_step "Verificando configuración actual de Git..."
CURRENT_HELPER=$(git config --global --get credential.helper 2>/dev/null || echo "")

if echo "$CURRENT_HELPER" | grep -q "aws codecommit credential-helper"; then
    print_success "Git Credential Helper de AWS ya está configurado"
    echo ""
    echo "Configuración actual:"
    git config --global --get credential.helper
    git config --global --get credential.UseHttpPath
    echo ""
    echo "✅ No se requieren cambios."
    exit 0
fi

# Configurar el helper
print_step "Configurando Git Credential Helper de AWS..."
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

print_success "Git Credential Helper de AWS configurado correctamente"
echo ""
echo "✅ Configuración completada!"
echo ""
echo "Ahora puedes hacer git clone de repositorios de CodeCommit sin ingresar credenciales."
echo "Git usará automáticamente las credenciales de AWS CLI."
echo ""
echo "Ejemplo:"
echo "  git clone https://git-codecommit.us-east-1.amazonaws.com/v1/repos/mi-repo"
echo ""

