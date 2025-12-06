#!/bin/bash

# Script de bloqueo bonito para i3
# Toma un screenshot, lo difumina y lo usa como fondo del lock
# Versión compatible con i3lock básico

# Crear directorio temporal si no existe
LOCK_DIR="$HOME/.cache/i3lock"
mkdir -p "$LOCK_DIR"

# Archivo temporal para el screenshot
LOCK_IMAGE="$LOCK_DIR/lock.png"

# Tomar screenshot y aplicar blur
scrot -z "$LOCK_IMAGE" 2>/dev/null || scrot "$LOCK_IMAGE"
convert "$LOCK_IMAGE" -blur 0x8 "$LOCK_IMAGE" 2>/dev/null || convert "$LOCK_IMAGE" -blur 0x6 "$LOCK_IMAGE"

# Verificar si i3lock-color está disponible (tiene más opciones)
if command -v i3lock-color &> /dev/null; then
    # Usar i3lock-color con todas las opciones de personalización
    i3lock-color \
        --image="$LOCK_IMAGE" \
        --inside-color=00000000 \
        --insidever-color=00000000 \
        --insidewrong-color=00000000 \
        --ring-color="#4299e1" \
        --ringver-color="#48bb78" \
        --ringwrong-color="#f56565" \
        --line-color=00000000 \
        --keyhl-color="#48bb78" \
        --bshl-color="#f56565" \
        --separator-color=00000000 \
        --verif-color="#e2e8f0" \
        --wrong-color="#e2e8f0" \
        --layout-color="#e2e8f0" \
        --time-color="#e2e8f0" \
        --date-color="#e2e8f0" \
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
        --timestr="%H:%M" \
        --datestr="%A, %d %B" \
        --nofork
else
    # Usar i3lock básico (compatible con todas las versiones)
    i3lock \
        --image="$LOCK_IMAGE" \
        --nofork \
        --indicator \
        --clock \
        --timestr="%H:%M" \
        --datestr="%A, %d %B"
fi

# Limpiar imagen temporal (opcional, puedes comentar esta línea si quieres mantenerla)
# rm "$LOCK_IMAGE"

