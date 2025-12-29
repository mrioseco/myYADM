#!/bin/bash

# Script para configurar Git Credential Helpers para múltiples servidores
# - AWS CodeCommit: usa AWS CLI credential helper
# - GitHub: usa store o token personal
# - GitLab: usa store o token personal

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

echo "🔐 Configurando Git Credential Helpers para múltiples servidores..."
echo ""

# Verificar que Git está instalado
print_step "Verificando Git..."
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado."
    exit 1
fi
print_success "Git está instalado"

# Configurar helper para AWS CodeCommit
print_step "Configurando helper para AWS CodeCommit..."
if command -v aws &> /dev/null; then
    # Verificar si AWS está configurado
    if [ -f "$HOME/.aws/credentials" ] && [ -f "$HOME/.aws/config" ]; then
        # Configurar helper específico para CodeCommit
        git config --global credential.https://git-codecommit.*.amazonaws.com.helper '!aws codecommit credential-helper $@'
        git config --global credential.https://git-codecommit.*.amazonaws.com.UseHttpPath true
        print_success "Helper de AWS CodeCommit configurado"
    else
        print_warning "AWS CLI no está configurado. Omitiendo configuración de CodeCommit."
        print_warning "Ejecuta 'aws configure' para configurar AWS CLI."
    fi
else
    print_warning "AWS CLI no está instalado. Omitiendo configuración de CodeCommit."
fi

# Configurar helper para GitHub
print_step "Configurando helper para GitHub..."
# Usar store como fallback, pero permitir que el usuario configure un token
git config --global credential.https://github.com.helper store
print_success "Helper de GitHub configurado (store)"

echo ""
print_warning "Para GitHub, puedes usar:"
echo "  1. Token personal (recomendado):"
echo "     - Crea un token en: https://github.com/settings/tokens"
echo "     - Usa el token como contraseña cuando Git lo solicite"
echo "     - Se guardará automáticamente en ~/.git-credentials"
echo ""
echo "  2. O configura SSH (más seguro):"
echo "     - Genera una clave SSH: ssh-keygen -t ed25519 -C 'tu-email@example.com'"
echo "     - Agrega la clave pública a GitHub: https://github.com/settings/keys"
echo "     - Cambia la URL del remote: git remote set-url origin git@github.com:usuario/repo.git"

# Configurar helper para GitLab
print_step "Configurando helper para GitLab..."
git config --global credential.https://gitlab.com.helper store
print_success "Helper de GitLab configurado (store)"

echo ""
print_warning "Para GitLab, puedes usar:"
echo "  1. Token personal:"
echo "     - Crea un token en: https://gitlab.com/-/user_settings/personal_access_tokens"
echo "     - Usa el token como contraseña cuando Git lo solicite"
echo ""
echo "  2. O configura SSH:"
echo "     - Genera una clave SSH: ssh-keygen -t ed25519 -C 'tu-email@example.com'"
echo "     - Agrega la clave pública a GitLab: https://gitlab.com/-/user_settings/ssh_keys"
echo "     - Cambia la URL del remote: git remote set-url origin git@gitlab.com:usuario/repo.git"

# Configurar helper genérico como fallback (para otros servidores)
print_step "Configurando helper genérico (fallback)..."
git config --global credential.helper store
print_success "Helper genérico configurado (store)"

echo ""
echo -e "${GREEN}✅ Configuración completada!${NC}"
echo ""
echo "Resumen de configuración:"
echo "  - AWS CodeCommit: usa AWS CLI credential helper"
echo "  - GitHub: usa store (guarda credenciales en ~/.git-credentials)"
echo "  - GitLab: usa store (guarda credenciales en ~/.git-credentials)"
echo "  - Otros servidores: usa store como fallback"
echo ""
echo "Para ver la configuración actual:"
echo "  git config --global --get-regexp credential"
echo ""
echo "💡 Tip: Cada repositorio puede tener su propia configuración en .git/config"
echo "💡 Tip: Para usar SSH en lugar de HTTPS, cambia la URL del remote:"
echo "   git remote set-url origin git@github.com:usuario/repo.git"

