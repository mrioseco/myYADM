#!/bin/bash

# Script para configurar GitHub con SSH (más seguro que tokens)

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

echo "🔐 Configurando GitHub con SSH..."
echo ""

# Verificar si ya existe una clave SSH
SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB="$HOME/.ssh/id_ed25519.pub"

if [ -f "$SSH_KEY" ]; then
    print_success "Clave SSH encontrada: $SSH_KEY"
else
    print_step "Generando nueva clave SSH..."
    read -p "Ingresa tu email de GitHub (presiona Enter para usar el configurado en Git): " email
    if [ -z "$email" ]; then
        email=$(git config --global user.email 2>/dev/null || echo "")
    fi
    if [ -z "$email" ]; then
        read -p "Email: " email
    fi
    
    ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
    print_success "Clave SSH generada"
fi

# Mostrar la clave pública
echo ""
print_step "Tu clave pública SSH:"
echo ""
cat "$SSH_PUB"
echo ""
print_warning "IMPORTANTE: Copia la clave pública de arriba y agrégala en GitHub:"
echo "  1. Ve a: https://github.com/settings/keys"
echo "  2. Haz clic en 'New SSH key'"
echo "  3. Dale un título (ej: 'Mi PC - Linux')"
echo "  4. Pega la clave pública"
echo "  5. Haz clic en 'Add SSH key'"
echo ""

read -p "¿Ya agregaste la clave en GitHub? (s/n): " agregada

if [ "$agregada" != "s" ] && [ "$agregada" != "S" ]; then
    print_warning "Por favor agrega la clave primero y luego ejecuta este script nuevamente."
    exit 0
fi

# Configurar SSH para GitHub
print_step "Configurando SSH para GitHub..."
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"

if [ ! -f "$SSH_CONFIG" ] || ! grep -q "Host github.com" "$SSH_CONFIG"; then
    cat >> "$SSH_CONFIG" << EOF

Host github.com
    HostName github.com
    User git
    IdentityFile $SSH_KEY
    IdentitiesOnly yes
EOF
    chmod 600 "$SSH_CONFIG"
    print_success "Configuración SSH agregada"
else
    print_success "Configuración SSH ya existe"
fi

# Probar conexión
print_step "Probando conexión SSH a GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    print_success "Conexión SSH exitosa"
else
    print_warning "La conexión puede requerir confirmación. Esto es normal la primera vez."
    ssh -T git@github.com || true
fi

echo ""
print_success "✅ Configuración SSH completada!"
echo ""
echo "Para cambiar un repositorio a SSH:"
echo "  git remote set-url origin git@github.com:usuario/repo.git"
echo ""
echo "Para cambiar el repositorio actual:"
echo "  git remote set-url origin git@github.com:\$(git config --get remote.origin.url | sed 's|https://github.com/||' | sed 's|\.git$||').git"

