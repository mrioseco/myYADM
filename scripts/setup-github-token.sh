#!/bin/bash

# Script para configurar GitHub con token personal
# Este script te guiará para crear y configurar un token de GitHub

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

echo "🔐 Configurando GitHub con token personal..."
echo ""

# Verificar que Git está instalado
if ! command -v git &> /dev/null; then
    print_error "Git no está instalado."
    exit 1
fi

print_step "Para autenticarte con GitHub, necesitas un token personal."
echo ""
echo "Pasos para crear un token:"
echo ""
echo "1. Ve a: https://github.com/settings/tokens"
echo "2. Haz clic en 'Generate new token' -> 'Generate new token (classic)'"
echo "3. Dale un nombre descriptivo (ej: 'Git CLI')"
echo "4. Selecciona los permisos necesarios:"
echo "   - Para repos privados: marca 'repo' (acceso completo a repositorios)"
echo "   - Para repos públicos: puedes usar permisos más limitados"
echo "5. Haz clic en 'Generate token'"
echo "6. COPIA EL TOKEN INMEDIATAMENTE (solo se muestra una vez)"
echo ""
echo -e "${YELLOW}⚠ IMPORTANTE: El token se mostrará solo una vez. Guárdalo en un lugar seguro.${NC}"
echo ""

read -p "¿Ya tienes un token? (s/n): " tiene_token

if [ "$tiene_token" != "s" ] && [ "$tiene_token" != "S" ]; then
    echo ""
    echo "Por favor crea el token primero siguiendo los pasos anteriores."
    echo "Luego ejecuta este script nuevamente."
    exit 0
fi

echo ""
read -sp "Pega tu token de GitHub: " github_token
echo ""

if [ -z "$github_token" ]; then
    print_error "No se proporcionó un token."
    exit 1
fi

# Obtener el usuario de GitHub desde la configuración de Git o preguntarlo
github_user=$(git config --global user.name 2>/dev/null || echo "")
if [ -z "$github_user" ]; then
    read -p "Ingresa tu usuario de GitHub: " github_user
fi

if [ -z "$github_user" ]; then
    print_error "Se requiere el usuario de GitHub."
    exit 1
fi

# Configurar el token en .git-credentials
print_step "Guardando credenciales..."
GIT_CREDENTIALS_FILE="$HOME/.git-credentials"
mkdir -p "$(dirname "$GIT_CREDENTIALS_FILE")"

# Agregar o actualizar la entrada de GitHub
if [ -f "$GIT_CREDENTIALS_FILE" ]; then
    # Eliminar entrada antigua de GitHub si existe
    sed -i '/github\.com/d' "$GIT_CREDENTIALS_FILE"
fi

# Agregar nueva entrada
echo "https://${github_user}:${github_token}@github.com" >> "$GIT_CREDENTIALS_FILE"

# Asegurar permisos seguros
chmod 600 "$GIT_CREDENTIALS_FILE"

print_success "Token de GitHub configurado correctamente"
echo ""
echo "✅ Ahora puedes hacer git push/pull a GitHub sin problemas."
echo ""
echo "El token se guardó en: $GIT_CREDENTIALS_FILE"
echo ""
echo "💡 Tip: Si necesitas revocar el token, ve a: https://github.com/settings/tokens"
echo "💡 Tip: Para usar SSH en lugar de HTTPS, ejecuta:"
echo "   git remote set-url origin git@github.com:${github_user}/repo.git"

