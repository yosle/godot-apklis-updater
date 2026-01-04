# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto se adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2025-12-31

### 🎉 Versión Mayor - Mejoras Significativas

Esta versión representa una reescritura completa del sistema con enfoque en robustez, extensibilidad y experiencia de desarrollo.

### ✨ Agregado

#### Sistema de Reintentos Automático
- Reintentos configurables ante errores de red (default: 2 reintentos)
- Delay configurable entre reintentos (default: 3 segundos)
- Logs detallados de cada intento
- Método `set_retry_config(max_retries, delay)` para configuración

#### Sistema de Cache Inteligente
- Cache automático de resultados por 5 minutos
- Reduce peticiones innecesarias a la API
- Configurable con `set_cache_enabled(bool)`
- Método `clear_cache()` para limpieza manual
- Opción `force_check` en `check_for_updates()` para ignorar cache

#### Múltiples Formas de Configuración
- Método `configure(package_name, version_code)` - forma recomendada
- Método `configure_from_project_settings()` - lee desde project.godot
- Método `configure_from_json(path)` - lee desde archivo JSON
- Auto-configuración en Android cuando es posible

#### API Asíncrona
- Nuevo método `check_for_updates_async()` con soporte para `await`
- Retorna Dictionary con resultado completo
- Timeout automático y manejo de errores

#### Sistema de Errores Mejorado
- Enum `ErrorCode` con códigos específicos:
  - `NONE` - Sin error
  - `NOT_CONFIGURED` - No está configurado
  - `NETWORK_ERROR` - Error de red
  - `HTTP_ERROR` - Error HTTP
  - `JSON_PARSE_ERROR` - Error parseando JSON
  - `NO_APP_FOUND` - App no encontrada
  - `NO_RELEASE_INFO` - Sin info de release
  - `TIMEOUT` - Timeout de conexión
  - `INVALID_PACKAGE_NAME` - Package name inválido
- Método `get_last_error_code()` para obtener código de error
- Método `get_last_error_string()` para descripción legible

#### Validación Exhaustiva
- Validación de formato de package name con regex
- Validación de respuestas de la API
- Validación de parámetros de configuración
- Mensajes de error descriptivos

#### Nuevos Métodos de Utilidad
- `get_status()` - Retorna Dictionary con estado completo del sistema
- `cancel_check()` - Cancela verificación en curso
- `set_timeout(seconds)` - Configura timeout HTTP
- Logs mejorados con prefijos `[ApklisUpdate] INFO/WARNING/ERROR`

#### Nuevas Señales
- `update_check_started()` - Emitida al iniciar verificación
- `configuration_changed()` - Emitida al cambiar configuración

#### Características Técnicas
- Inicialización lazy (sin problemas de timing con AutoLoad)
- Manejo inteligente de reintentos según tipo de error
- HTTP 400/404/403 no reintentan (errores del cliente)
- HTTP 500/502/503 sí reintentan (errores del servidor)
- Campo `check_timestamp` en `update_info` Dictionary

### 🔄 Cambiado

#### Comportamiento de Inicialización
- Ya NO verifica automáticamente en `_ready()` por defecto
- Requiere llamada explícita a `configure()` o configuración manual
- Evita problemas de timing y race conditions
- Permite mayor control sobre cuándo y cómo se verifica

#### Validación Mejorada
- Package names ahora se validan con regex
- Formato requerido: `com.empresa.app` (lowercase, puntos)
- Retorna `false` en `configure()` si el package name es inválido

#### Logs Mejorados
- Formato consistente: `[ApklisUpdate] LEVEL: mensaje`
- Más información de contexto en cada log
- Logs de reintentos con número de intento

#### User-Agent Actualizado
- De `GodotApklisChecker` a `GodotApklisChecker/2.0`

### 🐛 Corregido

- **CRÍTICO**: Solucionado problema de timing donde `package_name` no se configuraba antes de la verificación automática
- Mejor manejo de errores de parsing JSON
- Manejo correcto de apps sin información de release
- Validación de respuestas vacías de la API
- Race conditions en verificaciones concurrentes

### 📚 Documentación

#### Actualizada
- README.md completamente reescrito con v2.0
- API_REFERENCE.md expandida con nuevos métodos y ejemplos
- QUICK_START.md actualizada con nuevas formas de uso
- Ejemplos actualizados para v2.0

#### Agregada
- Sección "Novedades de la versión 2.0" en README
- Ejemplos de uso asíncrono con `await`
- Guía de migración desde v1.x
- Documentación de sistema de cache
- Documentación de sistema de reintentos
- Mejores prácticas actualizadas

### 🔧 Mejoras Internas

- Código reorganizado en regions para mejor navegación
- Constantes para valores por defecto
- Mejor separación de responsabilidades
- Métodos privados más granulares
- Timer dedicado para reintentos
- Manejo robusto de HTTPRequest

### ⚠️ Breaking Changes

**Ninguno - 100% Compatible con v1.x**

El código antiguo sigue funcionando sin cambios:
```gdscript
# v1.x - SIGUE FUNCIONANDO
ApklisUpdate.package_name = "cu.empresa.app"
ApklisUpdate.set_version_code(1)
ApklisUpdate.check_for_updates()
```

Solo se agregaron nuevas características y mejoras.

---

## [1.0.0] - 2025-12-30

### Agregado
- Sistema completo de verificación de actualizaciones para Apklis
- Clase `ApklisUpdateChecker` para manejar la verificación
- Clase `ApklisUpdateDialog` con diálogo personalizable
- Sistema de señales (`update_available`, `no_update_available`, `update_check_failed`)
- Soporte para AutoLoad en Godot 4
- Lectura automática del `version_code` en Android
- Método para establecer versión manualmente con `set_version_code()`
- Diálogo automático configurable
- Plugin de Godot para instalación fácil
- 7 ejemplos completos de integración

### Documentación
- README.md completo con ejemplos
- API_REFERENCE.md con referencia completa
- QUICK_START.md con guía de inicio rápido
- Comentarios extensivos en código GDScript
- LICENSE (MIT)
- .gitignore para proyectos Godot

### Características Técnicas
- Consulta a la API de Apklis (`https://api.apklis.cu/v1/application/`)
- Manejo robusto de errores de red
- Parsing seguro de JSON
- Comparación de códigos de versión
- Apertura de páginas en Apklis con `OS.shell_open()`
- Compatible con Godot 4.x

---

## [Unreleased]

---

## [2.1.0] - 2026-01-04

### 📦 Simplificación del Addon

Esta versión simplifica el addon eliminando el componente de diálogo personalizado, dándole a los usuarios control total sobre el diseño de su UI.

### 🐛 Corregido

#### Diálogo Básico Responsivo
- El diálogo básico ahora se ajusta automáticamente al tamaño del viewport
- Máximo 80% del ancho/alto de la pantalla
- Limita changelog a 200 caracteres para evitar diálogos muy grandes
- Funciona correctamente en juegos con resoluciones pequeñas (ej: 800x600)
- Texto más compacto para reducir tamaño

### 🗑️ Eliminado

#### Componente de Diálogo Personalizado
- **Archivos eliminados:**
  - `ApklisUpdateDialog.gd` - Componente de diálogo personalizado
  - `apklis_update_dialog.tscn` - Escena del diálogo

**Razón:** El componente de diálogo limitaba la flexibilidad y agregaba complejidad innecesaria. Ahora los usuarios tienen control total para implementar su propio diálogo con cualquier diseño.

### ✅ Agregado

#### Ejemplos Completos de Diálogo Personalizado
- `example_custom_dialog.gd` completamente reescrito
- Ejemplo simple: Diálogo básico con todos los elementos necesarios
- Ejemplo avanzado: Diálogo con animaciones y efectos visuales
- Todo implementado programáticamente para facilitar copia/adaptación

#### Documentación de Migración
- `MIGRATION_DIALOG_REMOVAL.md` - Guía completa de migración
- `CHANGES_SUMMARY.md` - Resumen de todos los cambios
- Scripts de limpieza (`cleanup_dialog.bat` y `cleanup_dialog.sh`)

### 🔄 Cambiado

#### ApklisUpdateChecker
- Comentario actualizado en `show_dialog_on_update` para clarificar que el diálogo incluido es básico
- Comentario actualizado en `_show_update_dialog()` para indicar su naturaleza simple
- Ahora usa solo `AcceptDialog` de Godot (más ligero)

#### Documentación Actualizada
- `README.md`: Características y estructura del proyecto actualizadas
- `QUICK_START.md`: Sección de instalación simplificada
- `API_REFERENCE.md`: Documentación de `show_dialog_on_update` clarificada
- `PROJECT_SUMMARY.md`: Estructura del proyecto actualizada
- `examples/README.md`: Ejemplo de diálogo personalizado actualizado

### ⭐ Beneficios

#### Para el Proyecto
- ✅ Código más simple y mantenible
- ✅ Menor acoplamiento entre componentes
- ✅ Addon más ligero (2 archivos menos)
- ✅ Responsabilidad única: solo verificar actualizaciones

#### Para los Usuarios
- ✅ Control total sobre el diseño del diálogo
- ✅ Ejemplos más educativos y completos
- ✅ Fácil de personalizar y adaptar
- ✅ Dos niveles de complejidad para elegir

### ⚠️ Migración Requerida

**Si usabas `ApklisUpdateDialog` directamente:**

1. El diálogo básico (`AcceptDialog`) sigue funcionando automáticamente
2. Para diálogo personalizado, consulta `examples/example_custom_dialog.gd`
3. Copia el código del ejemplo y adáptalo a tu juego
4. Ejecuta `cleanup_dialog.bat` (Windows) o `cleanup_dialog.sh` (Linux) para eliminar archivos antiguos

**Si solo usabas el sistema de verificación:**

No se requiere cambio alguno. El diálogo básico sigue funcionando igual.

### 📝 Notas

- Esta versión es **compatible** con v2.0.0
- El diálogo básico incluido sigue funcionando
- Los usuarios que quieran personalizar ahora tienen ejemplos completos
- Ver `MIGRATION_DIALOG_REMOVAL.md` para guía detallada

---

### Considerado para Futuras Versiones
- [ ] Descarga automática de APK
- [ ] Instalación automática (requiere permisos especiales)
- [ ] Notificaciones push para actualizaciones
- [ ] Historial de versiones instaladas
- [ ] Analytics de actualizaciones
- [ ] Soporte para múltiples idiomas en el diálogo
- [ ] Temas visuales personalizables
- [ ] Cache persistente entre sesiones
- [ ] Modo de actualización forzosa
- [ ] Detección de actualizaciones críticas/importantes
- [ ] Sistema de beta testing

---

## Comparación de Versiones

### v2.0.0 vs v1.0.0

| Característica | v1.0.0 | v2.0.0 |
|----------------|--------|--------|
| Reintentos automáticos | ❌ | ✅ |
| Sistema de cache | ❌ | ✅ (5 min) |
| API asíncrona (await) | ❌ | ✅ |
| Validación exhaustiva | Básica | Avanzada |
| Códigos de error | ❌ | ✅ Enum |
| Múltiples configs | ❌ | ✅ 3 formas |
| Logs detallados | Básicos | Completos |
| Manejo de timing | Problemático | Robusto |
| get_status() | ❌ | ✅ |
| cancel_check() | ❌ | ✅ |
| Timeout configurable | ❌ | ✅ |
| Compatibilidad v1 | - | ✅ 100% |

---

## Notas de Migración

### De v1.0.0 a v2.0.0

**Tu código antiguo sigue funcionando**, pero considera actualizar para aprovechar las nuevas características:

#### Antes (v1.x):
```gdscript
func _ready():
    ApklisUpdate.package_name = "cu.empresa.app"
    ApklisUpdate.set_version_code(1)
    ApklisUpdate.check_for_updates()
```

#### Después (v2.0 - Recomendado):
```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    ApklisUpdate.set_retry_config(3, 5.0)  # Nuevo
    ApklisUpdate.check_for_updates()
```

#### Ahora con await (v2.0):
```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    var result = await ApklisUpdate.check_for_updates_async()
    if result.has_update:
        print("Nueva versión!")
```

---

## Formato de Versiones

Este proyecto usa [Semantic Versioning](https://semver.org/):

- **MAJOR** (X.0.0): Cambios incompatibles en la API
- **MINOR** (0.X.0): Nueva funcionalidad compatible hacia atrás
- **PATCH** (0.0.X): Corrección de bugs compatible hacia atrás

---

## Enlaces

- [Apklis](https://www.apklis.cu) - Tienda de aplicaciones de Cuba
- [Godot Engine](https://godotengine.org) - Motor de juegos
- [Proyecto Original (Android)](https://github.com/Z17-CU/apklisupdate) - Inspiración
- [Keep a Changelog](https://keepachangelog.com/)
- [Semantic Versioning](https://semver.org/)

---

**Última actualización:** 31 de diciembre de 2025
**Versión actual:** 2.0.0
