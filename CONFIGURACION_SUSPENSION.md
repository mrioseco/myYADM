# Configuración de Suspensión y Cierre de Tapa

## Cambios Realizados en i3

Se ha comentado la línea de `xss-lock` en la configuración de i3 para evitar el bloqueo automático de pantalla al suspender. Esto elimina el mensaje "Verify" y "Ground" que aparecía al despertar.

## Configurar Comportamiento al Cerrar la Tapa

Para configurar qué sucede cuando cierras la tapa de tu laptop, necesitas modificar la configuración de systemd-logind.

### Opción 1: Cerrar Sesión al Cerrar la Tapa (Recomendado)

Esto cerrará tu sesión de usuario cuando cierres la tapa, sin suspender:

```bash
sudo nano /etc/systemd/logind.conf
```

Busca la línea que dice `#HandleLidSwitch=suspend` y cámbiala por:

```
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```

Luego reinicia el servicio:

```bash
sudo systemctl restart systemd-logind
```

### Opción 2: Suspender sin Bloquear

Si prefieres que se suspenda pero sin el bloqueo de pantalla (ya está configurado con el cambio en i3):

```bash
sudo nano /etc/systemd/logind.conf
```

Asegúrate de que tenga:

```
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
```

Y reinicia el servicio:

```bash
sudo systemctl restart systemd-logind
```

### Opción 3: Apagar al Cerrar la Tapa

Si quieres que se apague completamente:

```bash
sudo nano /etc/systemd/logind.conf
```

Cambia a:

```
HandleLidSwitch=poweroff
HandleLidSwitchExternalPower=poweroff
```

Y reinicia el servicio:

```bash
sudo systemctl restart systemd-logind
```

## Aplicar Cambios de i3 sin Reiniciar

Después de modificar `~/.config/i3/config`, puedes aplicar los cambios de dos formas:

### Método 1: Atajo de Teclado (Más Rápido)

Presiona: `Mod + Shift + c`

Esto recarga la configuración de i3 sin reiniciar.

### Método 2: Desde la Terminal

```bash
i3-msg reload
```

O si quieres reiniciar i3 completamente (preserva tu sesión):

```bash
i3-msg restart
```

O usando el atajo: `Mod + Shift + r`

## Verificar Configuración Actual

Para ver la configuración actual de logind:

```bash
cat /etc/systemd/logind.conf | grep HandleLid
```

## Nota

- Los cambios en `/etc/systemd/logind.conf` requieren permisos de administrador
- Después de modificar logind.conf, siempre reinicia el servicio con `sudo systemctl restart systemd-logind`
- Los cambios en i3 se aplican inmediatamente con `Mod + Shift + c`

