# Configuración de Git para Múltiples Servidores

Este documento explica cómo configurar Git para trabajar con múltiples servidores (AWS CodeCommit, GitHub, GitLab) sin conflictos.

## Problema Común

Cuando tienes múltiples servidores Git, cada uno requiere diferentes métodos de autenticación:
- **AWS CodeCommit**: Usa credenciales de AWS CLI
- **GitHub**: Usa token personal o SSH
- **GitLab**: Usa token personal o SSH

Si solo configuras un helper global, fallará para otros servidores.

## Solución: Helpers Específicos por URL

Git permite configurar diferentes credential helpers para diferentes URLs. Esto permite que cada servidor use su propio método de autenticación.

### Configuración Actual

La configuración actual usa helpers específicos por URL:

```bash
# AWS CodeCommit
credential.https://git-codecommit.*.amazonaws.com.helper = !aws codecommit credential-helper $@

# GitHub
credential.https://github.com.helper = store

# GitLab
credential.https://gitlab.com.helper = store
```

## Scripts Disponibles

### 1. Configurar Todos los Servidores

```bash
~/scripts/setup-git-credentials.sh
```

Este script configura helpers para:
- AWS CodeCommit (si AWS CLI está configurado)
- GitHub
- GitLab
- Fallback genérico para otros servidores

### 2. Configurar GitHub con Token

```bash
~/scripts/setup-github-token.sh
```

Este script te guía para:
1. Crear un token personal en GitHub
2. Guardarlo de forma segura
3. Configurarlo para uso automático

### 3. Configurar AWS CodeCommit

```bash
~/scripts/setup-aws-git-helper.sh
```

Este script configura el helper de AWS CodeCommit (requiere AWS CLI configurado).

## Autenticación por Servidor

### AWS CodeCommit

**Método**: AWS CLI Credential Helper

1. Configura AWS CLI:
   ```bash
   aws configure
   ```

2. Ejecuta el script:
   ```bash
   ~/scripts/setup-aws-git-helper.sh
   ```

3. Listo. Git usará automáticamente las credenciales de AWS.

### GitHub

**Opción 1: Token Personal (Recomendado para HTTPS)**

1. Crea un token en: https://github.com/settings/tokens
   - Haz clic en "Generate new token" -> "Generate new token (classic)"
   - Dale un nombre descriptivo
   - Selecciona permisos: `repo` (para repos privados)
   - Genera y copia el token

2. Ejecuta el script:
   ```bash
   ~/scripts/setup-github-token.sh
   ```

3. Pega el token cuando se solicite.

**Opción 2: SSH (Más Seguro)**

1. Genera una clave SSH:
   ```bash
   ssh-keygen -t ed25519 -C "tu-email@example.com"
   ```

2. Agrega la clave pública a GitHub:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   # Copia el contenido y agrégalo en: https://github.com/settings/keys
   ```

3. Cambia la URL del remote a SSH:
   ```bash
   git remote set-url origin git@github.com:usuario/repo.git
   ```

### GitLab

**Opción 1: Token Personal (Recomendado para HTTPS)**

1. Crea un token en: https://gitlab.com/-/user_settings/personal_access_tokens
   - Selecciona permisos: `read_repository`, `write_repository`
   - Genera y copia el token

2. La primera vez que hagas `git push`, Git te pedirá credenciales:
   - Usuario: tu usuario de GitLab
   - Contraseña: pega el token
   - Se guardará automáticamente en `~/.git-credentials`

**Opción 2: SSH (Más Seguro)**

1. Genera una clave SSH (si no tienes una):
   ```bash
   ssh-keygen -t ed25519 -C "tu-email@example.com"
   ```

2. Agrega la clave pública a GitLab:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   # Copia el contenido y agrégalo en: https://gitlab.com/-/user_settings/ssh_keys
   ```

3. Cambia la URL del remote a SSH:
   ```bash
   git remote set-url origin git@gitlab.com:usuario/repo.git
   ```

## Solución al Error del Socket de VS Code

Si ves este error:
```
Error: connect ECONNREFUSED /run/user/1000/vscode-git-8507c1a21a.sock
```

**Causa**: VS Code está intentando usar su propio helper de credenciales pero falla.

**Solución**:

1. Asegúrate de que los helpers específicos por URL estén configurados (ejecuta `setup-git-credentials.sh`)

2. Deshabilita el helper de VS Code en la configuración de Git:
   ```bash
   git config --global --unset credential.helper
   ```
   (Solo si estaba configurado globalmente sin especificar URL)

3. Verifica la configuración:
   ```bash
   git config --global --get-regexp credential
   ```

4. Si el problema persiste, reinicia VS Code/Cursor.

## Verificar Configuración

Para ver tu configuración actual:

```bash
git config --global --get-regexp credential
```

Deberías ver algo como:
```
credential.usehttppath true
credential.https://git-codecommit.*.amazonaws.com.helper !aws codecommit credential-helper $@
credential.https://git-codecommit.*.amazonaws.com.usehttppath true
credential.https://github.com.helper store
credential.https://gitlab.com.helper store
```

## Configuración por Repositorio

Cada repositorio puede tener su propia configuración en `.git/config`. Esto es útil si un repositorio específico necesita una configuración diferente.

Ejemplo: Cambiar un repositorio a SSH:
```bash
cd /ruta/al/repo
git remote set-url origin git@github.com:usuario/repo.git
```

## Troubleshooting

### "Missing or invalid credentials" en GitHub

1. Verifica que el helper esté configurado:
   ```bash
   git config --global --get credential.https://github.com.helper
   ```
   Debería mostrar: `store`

2. Si usas token, verifica que esté en `~/.git-credentials`:
   ```bash
   cat ~/.git-credentials | grep github
   ```

3. Si el token expiró, crea uno nuevo y actualiza `~/.git-credentials`

### "Authentication failed" en CodeCommit

1. Verifica que AWS CLI esté configurado:
   ```bash
   aws configure list
   ```

2. Verifica que el helper esté configurado:
   ```bash
   git config --global --get credential.https://git-codecommit.*.amazonaws.com.helper
   ```

3. Prueba las credenciales:
   ```bash
   aws codecommit list-repositories
   ```

## Notas Importantes

- Cada servidor puede usar su propio método de autenticación sin conflictos
- Los tokens se guardan en `~/.git-credentials` (asegúrate de proteger este archivo: `chmod 600 ~/.git-credentials`)
- SSH es más seguro que tokens, pero requiere configuración adicional
- Los helpers específicos por URL tienen prioridad sobre el helper genérico

