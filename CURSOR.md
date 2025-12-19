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

## 🔄 Actualizar Cursor

Si ya tienes Cursor instalado y quieres actualizarlo a una nueva versión:

### Pasos de Actualización

1. **Descargar la nueva versión:**
   - Visita https://cursor.sh/download
   - Descarga la última versión del AppImage para Linux (x86_64)
   - Renombra el archivo descargado a `Cursor.AppImage` (opcional, pero facilita el proceso)

2. **Cerrar Cursor (si está abierto):**
   ```bash
   # Asegúrate de cerrar todas las ventanas de Cursor antes de actualizar
   ```

3. **Extraer el nuevo AppImage:**
   ```bash
   # Navega a donde descargaste el AppImage
   cd ~/Downloads  # o donde lo hayas guardado
   
   # Si lo renombraste a Cursor.AppImage:
   ./Cursor.AppImage --appimage-extract
   
   # O si mantuviste el nombre original:
   # ./Cursor-X.X.X-x86_64.AppImage --appimage-extract
   ```

4. **Reemplazar la instalación anterior:**
   ```bash
   # Eliminar la versión anterior
   rm -rf ~/.local/share/cursor
   
   # Mover la nueva versión
   mv squashfs-root ~/.local/share/cursor
   ```

5. **Verificar la actualización:**
   ```bash
   cursor --version
   ```

### Resumen Rápido de Actualización

```bash
# 1. Descargar y renombrar a Cursor.AppImage (opcional)
# 2. Extraer
./Cursor.AppImage --appimage-extract

# 3. Reemplazar
rm -rf ~/.local/share/cursor
mv squashfs-root ~/.local/share/cursor

# 4. Verificar
cursor --version
```

**Nota:** El script en `~/.local/bin/cursor` no necesita ser recreado, ya apunta a la ubicación correcta.

## 📝 Notas

- El flag `--no-sandbox` es necesario para que Cursor funcione correctamente en algunos sistemas Linux
- Si renombras el AppImage a `Cursor.AppImage`, será más fácil recordar el comando de extracción
- El script en `~/.local/bin/cursor` no necesita cambios al actualizar, ya que apunta a `~/.local/share/cursor/AppRun`




