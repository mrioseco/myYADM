#!/bin/bash

# Script para actualizar el sistema y los gestores de paquetes disponibles
# Idealmente configurar aquí los comandos de actualización de ciertos comandos,
# solo se actualizarán los administradores de paquetes que se encuentren.

declare -A pmanagers

pmanagers["apt"]="sudo apt-get update && sudo apt-get upgrade -y"
pmanagers["npm"]="npm update -g"
pmanagers["yarn"]="yarn global upgrade"
pmanagers["brew"]="brew update && brew upgrade"

for clave in "${!pmanagers[@]}"; do
    if which "$clave" &> /dev/null; then
        echo "Actualizando $clave..."
        fun=${pmanagers["$clave"]}
        eval "$fun"
        echo "✓ $clave actualizado"
    fi  
done

echo "✅ Actualización completada"

