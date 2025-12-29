#!/bin/bash

# Script para configurar un helper personalizado que lea .git-credentials correctamente

set -e

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

echo "🔧 Configurando helper personalizado para Git credentials..."
echo ""

# Crear script helper personalizado
HELPER_SCRIPT="$HOME/.local/bin/git-credential-store-helper"
mkdir -p "$HOME/.local/bin"

cat > "$HELPER_SCRIPT" << 'HELPER_EOF'
#!/bin/bash
# Git credential helper que lee .git-credentials correctamente

action="$1"
if [ "$action" = "get" ]; then
    while IFS= read -r line; do
        if [[ "$line" =~ ^https://([^:]+):([^@]+)@([^/]+)(.*)$ ]]; then
            username="${BASH_REMATCH[1]}"
            password="${BASH_REMATCH[2]}"
            host="${BASH_REMATCH[3]}"
            path="${BASH_REMATCH[4]}"
            
            # Leer el host y path desde stdin
            read_host=""
            read_path=""
            while IFS= read -r input_line; do
                if [[ "$input_line" =~ ^host=(.+)$ ]]; then
                    read_host="${BASH_REMATCH[1]}"
                elif [[ "$input_line" =~ ^path=(.+)$ ]]; then
                    read_path="${BASH_REMATCH[4]}"
                fi
            done
            
            # Comparar host (sin https://)
            if [ "$read_host" = "$host" ] || [ "$read_host" = "github.com" -a "$host" = "github.com" ]; then
                echo "username=$username"
                echo "password=$password"
                exit 0
            fi
        fi
    done < "$HOME/.git-credentials"
fi
HELPER_EOF

chmod +x "$HELPER_SCRIPT"
print_success "Helper personalizado creado en $HELPER_SCRIPT"

# Agregar al PATH si no está
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
    print_success "Agregado $HOME/.local/bin al PATH"
fi

# Configurar el helper para GitHub
print_step "Configurando helper para GitHub..."
git config --global credential.https://github.com.helper "$HELPER_SCRIPT"
print_success "Helper configurado para GitHub"

echo ""
echo -e "${GREEN}✅ Configuración completada!${NC}"
echo ""
echo "Ahora puedes usar git push sin tener el token en la URL del remote."
echo ""
echo "Para actualizar el remote a la URL limpia:"
echo "  git remote set-url origin https://github.com/mrioseco/myYADM.git"

