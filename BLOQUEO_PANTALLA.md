# Bloqueo de Pantalla Personalizado

## 🎨 Características

El bloqueo de pantalla ha sido personalizado para ser más atractivo y funcional:

- **Fondo difuminado**: Toma un screenshot de tu escritorio y lo difumina como fondo
- **Colores modernos**: Esquema de colores azul/verde/rojo para diferentes estados
- **Reloj y fecha**: Muestra la hora y fecha actual en la pantalla de bloqueo
- **Indicador visual**: Anillo circular que cambia de color según el estado
- **Mensajes personalizados**: Textos en español para mejor experiencia

## 🎯 Cómo Usar

### Bloqueo Automático

El bloqueo se activa automáticamente cuando:
- Cierras la tapa del laptop (si está configurado para suspender)
- El sistema se suspende

### Bloqueo Manual

Presiona: `Mod + Shift + x`

Donde `Mod` es la tecla Windows/Super.

## 🎨 Personalización

Puedes personalizar los colores editando `~/scripts/lock.sh`:

```bash
# Colores actuales
TEXT_COLOR="#e2e8f0"      # Color del texto
RING_COLOR="#4299e1"       # Color del anillo (azul)
KEY_COLOR="#48bb78"        # Color al presionar teclas (verde)
WRONG_COLOR="#f56565"      # Color cuando la contraseña es incorrecta (rojo)
VERIFY_COLOR="#48bb78"     # Color al verificar (verde)
```

### Cambiar el Nivel de Blur

En la línea que dice:
```bash
convert "$LOCK_IMAGE" -blur 0x8 "$LOCK_IMAGE"
```

Cambia el `8` por un valor mayor (más blur) o menor (menos blur). Por ejemplo:
- `0x4` = blur suave
- `0x8` = blur medio (actual)
- `0x12` = blur fuerte

### Cambiar el Tamaño del Anillo

En las opciones de i3lock, busca:
```bash
--radius=180 \
--ring-width=8.0 \
```

- `radius`: Tamaño del círculo (180 = mediano)
- `ring-width`: Grosor del anillo (8.0 = mediano)

## 🔧 Archivos Relacionados

- **Script de bloqueo**: `~/scripts/lock.sh`
- **Configuración de i3**: `~/.config/i3/config`
- **Imágenes temporales**: `~/.cache/i3lock/`

## 📝 Notas

- Las imágenes de bloqueo se guardan temporalmente en `~/.cache/i3lock/`
- Puedes descomentar la última línea del script para limpiar automáticamente las imágenes
- El script requiere `scrot` e `imagemagick` (ya incluidos en el setup)

## 🐛 Solución de Problemas

**El bloqueo no muestra el fondo difuminado:**
- Verifica que ImageMagick está instalado: `which convert`
- Verifica que scrot está instalado: `which scrot`

**Los colores no se ven bien:**
- Asegúrate de que los códigos de color están en formato hexadecimal (#RRGGBB)
- Prueba con colores más contrastados si tienes problemas de visibilidad

**El bloqueo es muy lento:**
- Reduce el nivel de blur (cambia `0x8` a `0x4` o `0x6`)
- O comenta la línea de blur y usa un fondo sólido

## 🔄 Actualizar después de YADM Pull

Si acabas de hacer `yadm pull` y quieres aplicar los cambios del bloqueo de pantalla, sigue estos pasos:

### 1. Hacer el script ejecutable

YADM puede no preservar los permisos de ejecución, así que necesitas hacerlo manualmente:

```bash
chmod +x ~/scripts/lock.sh
```

### 2. Verificar/Instalar ImageMagick

El script requiere ImageMagick para el efecto de blur. Verifica si está instalado:

```bash
which convert
```

Si no está instalado, instálalo:

```bash
# Ubuntu/Debian
sudo apt-get install -y imagemagick

# Fedora/RHEL
sudo dnf install -y ImageMagick
```

### 3. Recargar la configuración de i3

Para que i3 use el nuevo script de bloqueo, recarga la configuración:

**Opción 1 - Atajo de teclado (más rápido):**
- Presiona: `Mod + Shift + c`

**Opción 2 - Desde la terminal:**
```bash
i3-msg reload
```

### 4. Verificar que funciona

Prueba el bloqueo manualmente:

```bash
~/scripts/lock.sh
```

O usa el atajo de teclado: `Mod + Shift + x`

### Resumen rápido

```bash
# Después de yadm pull, ejecuta:
chmod +x ~/scripts/lock.sh
sudo apt-get install -y imagemagick  # Solo si no está instalado
i3-msg reload
```

¡Listo! El bloqueo de pantalla personalizado debería estar funcionando.

