# My YADM - Configuración de PC

Repositorio público para gestionar y replicar la configuración completa de un PC usando YADM (Yet Another Dotfiles Manager).

## 🚀 Inicio Rápido

### En un PC Nuevo

1. **Instalar YADM:**

   ```bash
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y yadm

   # macOS (con Homebrew)
   brew install yadm
   ```

2. **Clonar este repositorio:**

   ```bash
   cd $HOME
   yadm clone https://github.com/TU_USUARIO/myYADM.git
   ```

3. **Ejecutar el script de configuración inicial:**

   ```bash
   chmod +x ~/setup.sh
   ~/setup.sh
   ```

   Este script instalará:

   - NVM (Node Version Manager)
   - Versiones de Node.js (14, 16, 18, 20, 22)
   - Cursor (editor de código)
   - i3 Window Manager y dependencias
   - Dependencias del sistema
   - Configuraciones personalizadas

   **⚠️ Nota importante sobre i3:**
   Después de ejecutar `setup.sh`, si i3 fue instalado, deberás:

   1. Cerrar sesión completamente
   2. En la pantalla de login, seleccionar "i3" como gestor de ventanas
   3. Iniciar sesión nuevamente con i3
   4. Continuar con la configuración desde la sesión de i3

## 📁 Estructura del Repositorio

```
myYADM/
├── README.md              # Este archivo
├── setup.sh               # Script de instalación inicial
├── install-nvm.sh         # Script para instalar NVM y Node.js
├── .shell_aliases         # Aliases de shell personalizados
├── .config/               # Configuraciones de aplicaciones
│   └── i3/                # Configuración de i3 Window Manager
│       └── config         # Archivo de configuración de i3
├── scripts/               # Scripts útiles
│   ├── update_system.sh   # Actualizar sistema y paquetes
│   └── newFeat.sh         # Helper para commits de features
└── bin/                   # Scripts ejecutables
    └── saludar.sh         # Script de ejemplo
```

## 🔧 Uso Diario

### Agregar una Nueva Configuración

```bash
# Agregar un archivo de configuración
yadm add ~/.config/algun-archivo.conf

# Hacer commit
yadm commit -m "Agregar configuración de X"

# Sincronizar con el repositorio remoto
yadm push
```

### Actualizar Configuraciones desde el Repositorio

```bash
yadm pull
```

### Ver Estado de los Archivos

```bash
yadm status
```

### Ver Historial

```bash
yadm log
```

## 📝 Aliases Disponibles

Los aliases están definidos en `.shell_aliases` y se cargan automáticamente. Algunos ejemplos:

- `gaa` - `git add -A`
- `gs` - `git status -sb`
- `gpl` - `git pull --rebase --autostash`
- `gps` - `git push`
- `c.` - Abrir Cursor en el directorio actual
- `up` - Actualizar sistema y paquetes

## 🛠️ Scripts Disponibles

### `setup.sh`

Script principal de instalación inicial. Ejecuta todas las configuraciones necesarias para un nuevo PC.

### `install-nvm.sh`

Instala NVM y las versiones de Node.js especificadas (14, 16, 18, 20, 22).

### `scripts/update_system.sh`

Actualiza el sistema operativo y los gestores de paquetes disponibles.

### `scripts/newFeat.sh`

Helper para crear commits de nuevas features con formato estándar.

## 🔄 Flujo de Trabajo Recomendado

1. **En tu PC actual:**

   - Realiza cambios en tus configuraciones
   - Agrega los archivos con `yadm add`
   - Haz commit con `yadm commit -m "Descripción"`
   - Sincroniza con `yadm push`

2. **En un PC nuevo:**
   - Clona el repositorio con `yadm clone`
   - Ejecuta `setup.sh` para instalar todo
   - Tus configuraciones estarán listas para usar

## 📦 Dependencias Instaladas

- **NVM** - Gestor de versiones de Node.js
- **Node.js** - Versiones 14, 16, 18, 20, 22
- **Cursor** - Editor de código
- **i3 Window Manager** - Tiling window manager
- **i3status** - Barra de estado para i3
- **i3lock** - Bloqueo de pantalla
- **dmenu** - Launcher de aplicaciones
- **Git** - Control de versiones
- **YADM** - Gestor de dotfiles

## 🪟 i3 Window Manager

Este repositorio incluye una configuración completa de i3, un tiling window manager para Linux.

### Configuración Incluida

- **Atajos de teclado personalizados** - Navegación y gestión de ventanas
- **Workspaces** - 10 workspaces configurables (1-10)
- **Screenshots** - Capturas de pantalla con `scrot`
- **Audio** - Control de volumen con teclas multimedia
- **Launcher** - Integración con `dmenu` y Cursor
- **Bloqueo automático** - Bloqueo de pantalla con `i3lock`

### Atajos de Teclado Principales

- **Mod** = Tecla Windows/Super

#### Navegación

- `Mod + j/k/l/ñ` - Cambiar foco entre ventanas
- `Mod + Shift + j/k/l/ñ` - Mover ventana
- `Mod + h/v` - Dividir ventana horizontal/verticalmente
- `Mod + f` - Pantalla completa
- `Mod + s/w/e` - Cambiar layout (stacking/tabbed/toggle split)

#### Workspaces

- `Mod + 1-10` - Cambiar a workspace
- `Mod + Shift + 1-10` - Mover ventana a workspace
- También funciona con el teclado numérico

#### Aplicaciones

- `Mod + Enter` - Abrir terminal
- `Mod + d` - Abrir dmenu (launcher)
- `Mod + Space` - Abrir carpeta de `~/code` en Cursor
- `Mod + g` - Clonar repositorio de AWS CodeCommit y abrir en Cursor

#### Utilidades

- `Mod + Shift + c` - Recargar configuración de i3
- `Mod + Shift + r` - Reiniciar i3
- `Mod + Shift + e` - Salir de i3
- `Print` - Captura de pantalla completa
- `Shift + Print` - Captura de pantalla seleccionada
- `Mod + Shift + Print` - Captura de ventana activa

### Personalizar i3

La configuración se encuentra en `~/.config/i3/config`. Después de modificar:

```bash
# Recargar configuración sin reiniciar
Mod + Shift + c

# O desde la terminal
i3-msg reload
```

### Solución de Problemas

**i3 no inicia después de la instalación:**

- Asegúrate de haber cerrado sesión y seleccionado "i3" en la pantalla de login
- Verifica que tienes un servidor X funcionando (normalmente viene con el sistema)

**La configuración no se aplica:**

- Verifica que el archivo está en `~/.config/i3/config`
- Revisa los logs: `i3-msg -t get_version`
- Recarga la configuración: `Mod + Shift + c`

## ⚙️ Personalización

### Agregar Nuevos Aliases

Edita `.shell_aliases` y haz commit:

```bash
yadm add .shell_aliases
yadm commit -m "Agregar nuevo alias"
yadm push
```

### Agregar Nuevos Scripts

1. Crea el script en `scripts/` o `bin/`
2. Hazlo ejecutable: `chmod +x scripts/mi-script.sh`
3. Agrega un alias si es necesario en `.shell_aliases`
4. Haz commit y push

## 🐛 Solución de Problemas

### YADM no encuentra los archivos

Asegúrate de estar en `$HOME` cuando clonas:

```bash
cd $HOME
yadm clone https://github.com/TU_USUARIO/myYADM.git
```

### Los aliases no funcionan

Verifica que tu shell carga `.shell_aliases`. Agrega a tu `.bashrc` o `.zshrc`:

```bash
[ -f ~/.shell_aliases ] && source ~/.shell_aliases
```

### Node.js no se encuentra después de instalar NVM

Cierra y abre una nueva terminal, o ejecuta:

```bash
source ~/.bashrc
# o
source ~/.zshrc
```

### i3 no aparece en la pantalla de login

Si i3 fue instalado pero no aparece como opción:

1. Verifica que i3 está instalado: `which i3`
2. Crea un archivo de sesión si es necesario (depende de tu gestor de login)
3. En algunos sistemas, necesitas instalar un paquete adicional como `i3-wm` o `i3-gaps`

### La configuración de i3 tiene errores

Si i3 no inicia o hay errores:

1. Verifica la sintaxis: `i3-config-wizard` (esto creará un backup)
2. Revisa los logs: `cat ~/.xsession-errors`
3. Prueba con configuración por defecto: `mv ~/.config/i3/config ~/.config/i3/config.backup`
4. Ejecuta `i3-config-wizard` para generar una nueva configuración base

## 📄 Licencia

Este repositorio es público y está disponible para uso personal.

## 🤝 Contribuciones

Este es un repositorio personal, pero siéntete libre de hacer fork y adaptarlo a tus necesidades.

---

**Nota:** Reemplaza `TU_USUARIO` con tu usuario de GitHub cuando clones el repositorio.
