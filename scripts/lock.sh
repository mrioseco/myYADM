#!/bin/bash

# Script de bloqueo bonito para i3
# Toma un screenshot, lo difumina y lo usa como fondo del lock

# Colores personalizados (esquema moderno)
TEXT_COLOR="#e2e8f0"            # Gris claro para el texto
RING_COLOR="#4299e1"            # Azul para el anillo
KEY_COLOR="#48bb78"             # Verde para las teclas
WRONG_COLOR="#f56565"           # Rojo para errores
VERIFY_COLOR="#48bb78"          # Verde para verificación

# Crear directorio temporal si no existe
LOCK_DIR="$HOME/.cache/i3lock"
mkdir -p "$LOCK_DIR"

# Archivo temporal para el screenshot
LOCK_IMAGE="$LOCK_DIR/lock.png"

# Tomar screenshot y aplicar blur
scrot -z "$LOCK_IMAGE"
convert "$LOCK_IMAGE" -blur 0x8 "$LOCK_IMAGE"

# Ejecutar i3lock con configuración bonita
i3lock \
    --image="$LOCK_IMAGE" \
    --inside-color=00000000 \
    --insidever-color=00000000 \
    --insidewrong-color=00000000 \
    --ring-color="$RING_COLOR" \
    --ringver-color="$VERIFY_COLOR" \
    --ringwrong-color="$WRONG_COLOR" \
    --line-color=00000000 \
    --keyhl-color="$KEY_COLOR" \
    --bshl-color="$WRONG_COLOR" \
    --separator-color=00000000 \
    --verif-color="$TEXT_COLOR" \
    --wrong-color="$TEXT_COLOR" \
    --layout-color="$TEXT_COLOR" \
    --time-color="$TEXT_COLOR" \
    --date-color="$TEXT_COLOR" \
    --greeter-color="$TEXT_COLOR" \
    --time-size=32 \
    --date-size=16 \
    --time-font="sans-serif" \
    --date-font="sans-serif" \
    --verif-text="Verificando..." \
    --wrong-text="Contraseña incorrecta" \
    --noinput-text="No hay entrada" \
    --lock-text="Bloqueando..." \
    --lockfailed-text="Error al bloquear" \
    --radius=180 \
    --ring-width=8.0 \
    --indicator \
    --clock \
    --nofork

# Limpiar imagen temporal (opcional, puedes comentar esta línea si quieres mantenerla)
# rm "$LOCK_IMAGE"

