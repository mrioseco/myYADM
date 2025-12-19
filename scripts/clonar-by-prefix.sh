#!/bin/bash

# Este script lista todas las funciones de AWS Lambda que coinciden con un prefijo dado
# y clona sus repositorios de CodeCommit en ~/code/

# Comprobamos si se ha proporcionado un prefijo
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <prefijo>"
    echo "Ejemplo: $0 my-project"
    exit 1
fi

PREFIJO=$1
REGION="us-east-1"
CODE_DIR="$HOME/code"

# Verificar que AWS CLI está instalado
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI no está instalado."
    echo "Instálalo con: sudo apt-get install -y awscli"
    exit 1
fi

# Verificar que jq está instalado
if ! command -v jq &> /dev/null; then
    echo "Error: jq no está instalado."
    echo "Instálalo con: sudo apt-get install -y jq"
    exit 1
fi

# Verificar que el directorio code existe, si no crearlo
if [ ! -d "$CODE_DIR" ]; then
    echo "Creando directorio $CODE_DIR..."
    mkdir -p "$CODE_DIR"
fi

# Cambiar al directorio code
cd "$CODE_DIR" || exit 1

echo "🔍 Buscando funciones Lambda con prefijo: $PREFIJO"
echo "📁 Clonando en: $CODE_DIR"
echo ""

# Obtener lista de funciones Lambda y filtrar por prefijo
FUNCTIONS=$(aws lambda list-functions --region "$REGION" 2>/dev/null | jq -r ".Functions[] | select(.FunctionName | startswith(\"$PREFIJO\")) | .FunctionName")

if [ -z "$FUNCTIONS" ]; then
    echo "⚠️  No se encontraron funciones Lambda con el prefijo: $PREFIJO"
    exit 1
fi

# Contar funciones encontradas
COUNT=$(echo "$FUNCTIONS" | wc -l)
echo "✅ Se encontraron $COUNT función(es) con el prefijo '$PREFIJO'"
echo ""

# Clonar cada repositorio
SUCCESS=0
FAILED=0
EXISTING=0

while IFS= read -r function_name; do
    if [ -n "$function_name" ]; then
        REPO_URL="https://git-codecommit.$REGION.amazonaws.com/v1/repos/$function_name"
        
        # Verificar si el directorio ya existe
        if [ -d "$CODE_DIR/$function_name" ]; then
            echo "⏭️  Saltando $function_name (ya existe en $CODE_DIR)"
            EXISTING=$((EXISTING + 1))
        else
            echo "📦 Clonando $function_name..."
            if git clone "$REPO_URL" "$function_name" 2>/dev/null; then
                echo "   ✅ $function_name clonado exitosamente"
                SUCCESS=$((SUCCESS + 1))
            else
                echo "   ❌ Error al clonar $function_name"
                FAILED=$((FAILED + 1))
            fi
        fi
        echo ""
    fi
done <<< "$FUNCTIONS"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✨ Proceso completado"
echo "   Exitosos: $SUCCESS"
echo "   Fallidos: $FAILED"
echo "   Ya existían: $EXISTING"

