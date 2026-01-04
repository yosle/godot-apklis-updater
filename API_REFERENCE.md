# 📚 Referencia Completa de la API - v2.0

## Clase: ApklisUpdateChecker

### Descripción
Sistema robusto de verificación de actualizaciones para aplicaciones publicadas en Apklis. Incluye reintentos automáticos, cache, validación exhaustiva y múltiples formas de configuración.

### Herencia
```
Node → ApklisUpdateChecker
```

---

## 🎯 Propiedades Públicas

### package_name
```gdscript
var package_name: String = ""
```
**Descripción:** Nombre del paquete de la aplicación en Apklis (ej: "cu.empresa.app")  
**Formato:** Debe seguir el patrón `com.empresa.app` (lowercase, separado por puntos)  
**Requerido:** Sí  
**Validación:** Se valida automáticamente con regex  

---

### current_version_code
```gdscript
var current_version_code: int = 0
```
**Descripción:** Código de versión actual de la aplicación  
**Nota:** Se obtiene automáticamente en Android. Puede establecerse manualmente.  
**Rango:** Entero positivo

---

### show_dialog_on_update
```gdscript
var show_dialog_on_update: bool = true
```
**Descripción:** Si es `true`, muestra automáticamente un diálogo simple cuando hay actualización disponible  
**Default:** `true`  
**Nota:** El diálogo incluido es básico (AcceptDialog de Godot). Para un diálogo personalizado, establece esto en `false` y conecta la señal `update_available` para mostrar tu propio diálogo con el diseño que prefieras

---

### request_timeout
```gdscript
var request_timeout: float = 30.0
```
**Descripción:** Timeout en segundos para las peticiones HTTP  
**Default:** `30.0`  
**Rango:** Mínimo 1.0 segundo  
**Uso:** `ApklisUpdate.set_timeout(45.0)`

---

### max_retries
```gdscript
var max_retries: int = 2
```
**Descripción:** Número máximo de reintentos en caso de error  
**Default:** `2`  
**Rango:** 0 o más  
**Uso:** `ApklisUpdate.set_retry_config(3, 5.0)`

---

### retry_delay
```gdscript
var retry_delay: float = 3.0
```
**Descripción:** Tiempo de espera en segundos entre reintentos  
**Default:** `3.0`  
**Rango:** Mínimo 0.1 segundos  
**Uso:** `ApklisUpdate.set_retry_config(2, 5.0)`

---

### use_cache
```gdscript
var use_cache: bool = true
```
**Descripción:** Si es `true`, cachea los resultados por 5 minutos  
**Default:** `true`  
**Duración:** 5 minutos (300 segundos)  
**Uso:** `ApklisUpdate.set_cache_enabled(false)`

---

## 🔧 Métodos de Configuración

### configure()
```gdscript
func configure(pkg_name: String, version_code: int = 0) -> bool
```
**Descripción:** Configura el checker con package name y versión. **Método recomendado**.

**Parámetros:**
- `pkg_name` (String): Nombre del paquete (ej: "cu.empresa.app")
- `version_code` (int, opcional): Código de versión actual (default: 0)

**Retorna:** `bool` - `true` si la configuración fue exitosa, `false` si el package name es inválido

**Validación:** Valida el formato del package name con regex

**Ejemplo:**
```gdscript
if ApklisUpdate.configure("cu.empresa.mijuego", 1):
    ApklisUpdate.check_for_updates()
else:
    push_error("Package name inválido")
```

---

### configure_from_project_settings()
```gdscript
func configure_from_project_settings() -> bool
```
**Descripción:** Lee la configuración desde `project.godot`

**Settings requeridos:**
- `application/config/apklis_package_name` (String)
- `application/config/version_code` (int, opcional)

**Retorna:** `bool` - `true` si encontró y aplicó la configuración

**Ejemplo:**
```gdscript
# En project.godot:
# [application]
# config/apklis_package_name="cu.empresa.app"
# config/version_code=1

# En tu código:
if ApklisUpdate.configure_from_project_settings():
    ApklisUpdate.check_for_updates()
```

---

### configure_from_json()
```gdscript
func configure_from_json(json_path: String) -> bool
```
**Descripción:** Lee la configuración desde un archivo JSON

**Parámetros:**
- `json_path` (String): Ruta al archivo JSON (ej: "res://config.json")

**Formato JSON esperado:**
```json
{
  "package_name": "cu.empresa.app",
  "version_code": 1
}
```

**Retorna:** `bool` - `true` si leyó y aplicó la configuración correctamente

**Ejemplo:**
```gdscript
if ApklisUpdate.configure_from_json("res://apklis_config.json"):
    ApklisUpdate.check_for_updates()
```

---

### set_retry_config()
```gdscript
func set_retry_config(max_retry: int, delay: float) -> void
```
**Descripción:** Configura el sistema de reintentos

**Parámetros:**
- `max_retry` (int): Número máximo de reintentos (mínimo: 0)
- `delay` (float): Segundos entre reintentos (mínimo: 0.1)

**Ejemplo:**
```gdscript
# 3 reintentos, 5 segundos entre cada uno
ApklisUpdate.set_retry_config(3, 5.0)
```

---

### set_timeout()
```gdscript
func set_timeout(timeout: float) -> void
```
**Descripción:** Establece el timeout de las peticiones HTTP

**Parámetros:**
- `timeout` (float): Segundos de timeout (mínimo: 1.0)

**Ejemplo:**
```gdscript
ApklisUpdate.set_timeout(45.0)  # 45 segundos
```

---

### set_cache_enabled()
```gdscript
func set_cache_enabled(enabled: bool) -> void
```
**Descripción:** Habilita o deshabilita el sistema de cache

**Parámetros:**
- `enabled` (bool): `true` para habilitar, `false` para deshabilitar

**Nota:** Si se deshabilita, limpia el cache automáticamente

**Ejemplo:**
```gdscript
ApklisUpdate.set_cache_enabled(false)  # Deshabilitar cache
```

---

### clear_cache()
```gdscript
func clear_cache() -> void
```
**Descripción:** Limpia manualmente el cache de resultados

**Ejemplo:**
```gdscript
ApklisUpdate.clear_cache()
ApklisUpdate.check_for_updates()  # Forzar verificación fresca
```

---

## 🚀 Métodos de Verificación

### check_for_updates()
```gdscript
func check_for_updates(force_check: bool = false) -> bool
```
**Descripción:** Verifica si hay actualizaciones disponibles

**Parámetros:**
- `force_check` (bool, opcional): Si es `true`, ignora el cache y fuerza una verificación nueva

**Retorna:** `bool` - `true` si la verificación se inició correctamente, `false` si hay un error

**Comportamiento:**
- Si está en cache y `force_check=false`, emite resultado inmediatamente
- Si ya hay verificación en curso, retorna `false`
- Si no está configurado, retorna `false` y emite `update_check_failed`

**Ejemplo:**
```gdscript
# Verificación normal (usa cache si está disponible)
ApklisUpdate.check_for_updates()

# Forzar verificación (ignora cache)
ApklisUpdate.check_for_updates(true)
```

---

### check_for_updates_async()
```gdscript
func check_for_updates_async() -> Dictionary
```
**Descripción:** Versión asíncrona que espera y retorna el resultado

**Retorna:** `Dictionary` con el resultado de la verificación

**Estructura del Dictionary retornado:**
```gdscript
# Si hay actualización:
{
    "has_update": true,
    "app_name": "Mi App",
    "latest_version_name": "1.2.0",
    # ... otros campos de update_info
}

# Si no hay actualización:
{
    "has_update": false,
    # ... campos de update_info
}

# Si hay error:
{
    "has_update": false,
    "error": "Network error"
}
```

**Ejemplo:**
```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    
    var result = await ApklisUpdate.check_for_updates_async()
    
    if result.has("error"):
        print("Error: ", result.error)
    elif result.has_update:
        print("¡Hay actualización!")
        print("Nueva versión: ", result.latest_version_name)
    else:
        print("Estás actualizado")
```

---

### cancel_check()
```gdscript
func cancel_check() -> void
```
**Descripción:** Cancela la verificación en curso

**Nota:** No emite señales al cancelar

**Ejemplo:**
```gdscript
ApklisUpdate.check_for_updates()

# Cancelar después de 5 segundos
await get_tree().create_timer(5.0).timeout
ApklisUpdate.cancel_check()
```

---

## 📊 Métodos de Utilidad

### get_status()
```gdscript
func get_status() -> Dictionary
```
**Descripción:** Retorna el estado actual completo del sistema

**Retorna:** Dictionary con información de estado

**Estructura:**
```gdscript
{
    "is_configured": bool,     # Si está configurado
    "is_checking": bool,       # Si está verificando ahora
    "package_name": String,    # Package name configurado
    "version_code": int,       # Versión configurada
    "last_error": ErrorCode,   # Último error (enum)
    "cache_valid": bool,       # Si el cache es válido
    "retry_count": int,        # Número de reintentos actuales
}
```

**Ejemplo:**
```gdscript
var status = ApklisUpdate.get_status()
print("Configurado: ", status.is_configured)
print("Verificando: ", status.is_checking)
print("Cache válido: ", status.cache_valid)
```

---

### get_last_error_code()
```gdscript
func get_last_error_code() -> ErrorCode
```
**Descripción:** Retorna el último código de error

**Retorna:** `ErrorCode` (enum)

**Ejemplo:**
```gdscript
var error = ApklisUpdate.get_last_error_code()
if error == ApklisUpdateChecker.ErrorCode.NETWORK_ERROR:
    print("Problema de red")
```

---

### get_last_error_string()
```gdscript
func get_last_error_string() -> String
```
**Descripción:** Retorna descripción legible del último error

**Retorna:** String con descripción del error

**Posibles valores:**
- `"No error"`
- `"Not configured"`
- `"Network error"`
- `"HTTP error"`
- `"JSON parse error"`
- `"App not found"`
- `"No release info"`
- `"Timeout"`
- `"Invalid package name"`

**Ejemplo:**
```gdscript
ApklisUpdate.update_check_failed.connect(func(error):
    print("Error: ", ApklisUpdate.get_last_error_string())
)
```

---

## 📡 Señales

### update_available
```gdscript
signal update_available(update_info: Dictionary)
```
**Descripción:** Emitida cuando se detecta una actualización disponible

**Cuándo se emite:**
- `latest_version_code > current_version_code`
- Después de verificación exitosa

**Parámetros:**
- `update_info` (Dictionary): Información completa de la actualización

**Estructura de update_info:**
```gdscript
{
    "app_name": String,              # Nombre de la app
    "package_name": String,          # Identificador del paquete
    "description": String,           # Descripción
    "current_version_code": int,     # Versión actual instalada
    "latest_version_code": int,      # Última versión en Apklis
    "latest_version_name": String,   # Nombre de versión (ej: "1.2.0")
    "changelog": String,             # Lista de cambios
    "download_url": String,          # URL del APK
    "size": String,                  # Tamaño legible (ej: "50 MB")
    "icon": String,                  # URL del icono
    "rating": float,                 # Calificación 0-5
    "download_count": int,           # Número de descargas
    "check_timestamp": int,          # Unix timestamp
}
```

**Ejemplo:**
```gdscript
ApklisUpdate.update_available.connect(func(info):
    print("Nueva versión: ", info.latest_version_name)
    print("Tamaño: ", info.size)
    print("Cambios: ", info.changelog)
)
```

---

### no_update_available
```gdscript
signal no_update_available(current_info: Dictionary)
```
**Descripción:** Emitida cuando NO hay actualizaciones (app actualizada)

**Cuándo se emite:**
- `latest_version_code <= current_version_code`
- Después de verificación exitosa

**Parámetros:**
- `current_info` (Dictionary): Información de la versión actual (misma estructura que `update_info`)

**Ejemplo:**
```gdscript
ApklisUpdate.no_update_available.connect(func(info):
    print("Estás en la última versión: v", info.latest_version_name)
)
```

---

### update_check_failed
```gdscript
signal update_check_failed(error: String)
```
**Descripción:** Emitida cuando ocurre un error durante la verificación

**Cuándo se emite:**
- Error de red
- Error HTTP (400, 404, 500, etc)
- Error parseando JSON
- App no encontrada
- No configurado
- Package name inválido

**Parámetros:**
- `error` (String): Descripción del error

**Ejemplo:**
```gdscript
ApklisUpdate.update_check_failed.connect(func(error):
    print("Error: ", error)
    var code = ApklisUpdate.get_last_error_code()
    match code:
        ApklisUpdateChecker.ErrorCode.NETWORK_ERROR:
            print("Sin conexión")
        ApklisUpdateChecker.ErrorCode.NO_APP_FOUND:
            print("App no está en Apklis")
)
```

---

### update_check_started
```gdscript
signal update_check_started()
```
**Descripción:** Emitida cuando inicia una verificación

**Cuándo se emite:**
- Al llamar `check_for_updates()` exitosamente
- Antes de hacer la petición HTTP

**Ejemplo:**
```gdscript
ApklisUpdate.update_check_started.connect(func():
    status_label.text = "Verificando..."
    spinner.visible = true
)
```

---

### configuration_changed
```gdscript
signal configuration_changed()
```
**Descripción:** Emitida cuando cambia la configuración

**Cuándo se emite:**
- Al llamar `configure()`
- Al llamar `configure_from_project_settings()`
- Al llamar `configure_from_json()`

**Ejemplo:**
```gdscript
ApklisUpdate.configuration_changed.connect(func():
    print("Configuración actualizada")
    _update_ui()
)
```

---

## 🔢 Enumeraciones

### ErrorCode
```gdscript
enum ErrorCode {
    NONE = 0,                  # Sin error
    NOT_CONFIGURED = 1,        # No configurado
    NETWORK_ERROR = 2,         # Error de red
    HTTP_ERROR = 3,            # Error HTTP (500, 503, etc)
    JSON_PARSE_ERROR = 4,      # Error parseando JSON
    NO_APP_FOUND = 5,          # App no encontrada
    NO_RELEASE_INFO = 6,       # Sin info de release
    TIMEOUT = 7,               # Timeout de conexión
    INVALID_PACKAGE_NAME = 8,  # Package name inválido
}
```

**Descripción:** Códigos de error específicos para mejor diagnóstico

**Uso:**
```gdscript
var error = ApklisUpdate.get_last_error_code()
if error == ApklisUpdateChecker.ErrorCode.NETWORK_ERROR:
    retry_later()
elif error == ApklisUpdateChecker.ErrorCode.NO_APP_FOUND:
    show_error("App no publicada en Apklis")
```

---

## 🔐 Constantes

### APKLIS_API_URL
```gdscript
const APKLIS_API_URL = "https://api.apklis.cu/v1/application/"
```
**Descripción:** URL base de la API de Apklis

---

### DEFAULT_TIMEOUT
```gdscript
const DEFAULT_TIMEOUT = 30.0
```
**Descripción:** Timeout por defecto en segundos

---

### DEFAULT_MAX_RETRIES
```gdscript
const DEFAULT_MAX_RETRIES = 2
```
**Descripción:** Número de reintentos por defecto

---

### DEFAULT_RETRY_DELAY
```gdscript
const DEFAULT_RETRY_DELAY = 3.0
```
**Descripción:** Delay entre reintentos por defecto

---

### CACHE_DURATION
```gdscript
const CACHE_DURATION = 300.0
```
**Descripción:** Duración del cache en segundos (5 minutos)

---

## 📖 Ejemplos Completos

### Ejemplo 1: Configuración Básica
```gdscript
extends Node2D

func _ready():
    # Configurar
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    
    # Conectar señales
    ApklisUpdate.update_available.connect(_on_update_available)
    ApklisUpdate.no_update_available.connect(_on_no_update)
    ApklisUpdate.update_check_failed.connect(_on_check_failed)
    
    # Verificar
    ApklisUpdate.check_for_updates()

func _on_update_available(info: Dictionary):
    print("¡Actualización disponible!")
    print("Nueva versión: ", info.latest_version_name)

func _on_no_update(info: Dictionary):
    print("Todo actualizado")

func _on_check_failed(error: String):
    print("Error: ", error)
```

---

### Ejemplo 2: Uso Asíncrono
```gdscript
extends Control

@onready var status_label = $StatusLabel

func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    _check_updates()

func _check_updates():
    status_label.text = "Verificando..."
    
    var result = await ApklisUpdate.check_for_updates_async()
    
    if result.has("error"):
        status_label.text = "Error: " + result.error
    elif result.has_update:
        status_label.text = "¡Hay actualización!"
        _show_update_dialog(result)
    else:
        status_label.text = "Todo actualizado"
```

---

### Ejemplo 3: Sistema de Reintentos
```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    
    # Configurar reintentos agresivos
    ApklisUpdate.set_retry_config(5, 10.0)  # 5 reintentos, 10s entre ellos
    ApklisUpdate.set_timeout(60.0)  # 60 segundos de timeout
    
    ApklisUpdate.update_check_failed.connect(_on_failed)
    ApklisUpdate.check_for_updates()

func _on_failed(error: String):
    var status = ApklisUpdate.get_status()
    print("Falló después de %d reintentos" % status.retry_count)
```

---

### Ejemplo 4: Debug Completo
```gdscript
func _input(event):
    if event.is_action_pressed("ui_text_completion_replace"):  # F5
        _show_debug_panel()

func _show_debug_panel():
    var status = ApklisUpdate.get_status()
    
    print("\n╔════════════════════════════════════════╗")
    print("║   DEBUG: ApklisUpdate                  ║")
    print("╚════════════════════════════════════════╝")
    print("Configurado:    ", status.is_configured)
    print("Verificando:    ", status.is_checking)
    print("Package:        ", status.package_name)
    print("Versión:        ", status.version_code)
    print("Cache válido:   ", status.cache_valid)
    print("Reintentos:     ", status.retry_count)
    print("Último error:   ", ApklisUpdate.get_last_error_string())
    print("═══════════════════════════════════════════\n")
    
    # Forzar verificación
    ApklisUpdate.check_for_updates(true)
```

---

### Ejemplo 5: Verificación con Cache Inteligente
```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    
    # Primera llamada - verifica en API
    ApklisUpdate.check_for_updates()
    
    await get_tree().create_timer(2.0).timeout
    
    # Segunda llamada - usa cache (instantáneo)
    ApklisUpdate.check_for_updates()
    
    await get_tree().create_timer(10.0).timeout
    
    # Forzar nueva verificación (ignora cache)
    ApklisUpdate.check_for_updates(true)
```

---

## 🎯 Mejores Prácticas

### 1. Siempre verifica el retorno de configure()
```gdscript
# ✅ Bueno
if not ApklisUpdate.configure("cu.empresa.app", 1):
    push_error("Configuración falló")
    return

# ❌ Malo
ApklisUpdate.configure("cu.empresa.app", 1)  # No verifica errores
```

---

### 2. Usa await para flujo secuencial
```gdscript
# ✅ Bueno - flujo claro
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    var result = await ApklisUpdate.check_for_updates_async()
    if result.has_update:
        show_dialog()

# ❌ Evitar - callbacks anidados complejos
```

---

### 3. Maneja errores apropiadamente
```gdscript
# ✅ Bueno - no molestar al usuario
ApklisUpdate.update_check_failed.connect(func(error):
    # Log silencioso
    print("Error: ", error)
)

# ❌ Malo - mostrar error técnico al usuario
ApklisUpdate.update_check_failed.connect(func(error):
    var dialog = AcceptDialog.new()
    dialog.dialog_text = error  # Muy técnico
    add_child(dialog)
    dialog.popup()
)
```

---

### 4. Limita la frecuencia de verificaciones
```gdscript
# ✅ Bueno - verificar una vez al día
const CHECK_INTERVAL = 86400  # 24 horas

func should_check_updates() -> bool:
    var last_check = SaveSystem.get_last_update_check()
    var now = Time.get_unix_time_from_system()
    return now - last_check >= CHECK_INTERVAL

func _ready():
    if should_check_updates():
        ApklisUpdate.check_for_updates()
        SaveSystem.save_last_update_check()
```

---

### 5. Usa cache para mejorar UX
```gdscript
# ✅ Bueno - verificación rápida con cache
func _on_settings_opened():
    # Usa cache si está disponible (instantáneo)
    ApklisUpdate.check_for_updates()

func _on_force_check_pressed():
    # Fuerza verificación nueva
    ApklisUpdate.check_for_updates(true)
```

---

## ⚠️ Limitaciones

1. **Solo Android**: Diseñado para Apklis (Android)
2. **Requiere Internet**: No funciona offline
3. **Rate Limiting**: Respeta los límites de la API de Apklis
4. **Cache limitado**: 5 minutos, no persiste entre sesiones
5. **Sin auto-actualización**: Solo notifica, no descarga/instala

---

## 📞 Soporte

- 📝 [Reportar Issue](https://github.com/tu-repo/issues)
- 💬 Comunidad Godot Cuba
- 📖 [Guía Rápida](QUICK_START.md)
- 📦 [Ejemplos](examples/)

---

**Última actualización:** v2.0 - Diciembre 2025
