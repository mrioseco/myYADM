# Instalación Manual de Cursor

Cursor debe instalarse manualmente desde su sitio web oficial. Este documento describe el proceso de instalación usando el AppImage.

## Pasos de Instalación

### 1️⃣ Descargar el AppImage

1. Visita https://cursor.sh/download
2. Descarga la última versión del AppImage para Linux (x86_64)
3. Guarda el archivo en tu directorio de descargas o en un lugar temporal

### 2️⃣ Extraer el AppImage

**⚠️ Importante:** No uses `--install`, mejor lo instalamos manualmente.

```bash
./Cursor-2.1.49-x86_64.AppImage --appimage-extract
```

Esto crea una carpeta llamada `squashfs-root/` en el directorio actual.

### 3️⃣ Mover la aplicación a tu carpeta local

```bash
mv squashfs-root ~/.local/share/cursor
```

### 4️⃣ Crear un script ejecutable sin sandbox

Crea un script ejecutable que lance Cursor sin sandbox:

```bash
echo '#!/bin/bash
HOME=$HOME ~/.local/share/cursor/AppRun --no-sandbox "$@"' > ~/.local/bin/cursor

chmod +x ~/.local/bin/cursor
```

### 5️⃣ Verificar la instalación

Asegúrate de que `~/.local/bin` esté en tu PATH. Si no lo está, agrégalo a tu `~/.bashrc` o `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Luego verifica que Cursor funciona:

```bash
cursor --version
```

## Notas

- El flag `--no-sandbox` es necesario para que Cursor funcione correctamente en algunos sistemas Linux
- Si actualizas Cursor, repite los pasos 2-4 con la nueva versión del AppImage
- El script en `~/.local/bin/cursor` puede ser actualizado manualmente si cambias la ubicación de la instalación




