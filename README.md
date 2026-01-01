# 🚀 Godot Apklis Updater

```
 ██████╗  ██████╗ ██████╗  ██████╗ ████████╗    
██╔════╝ ██╔═══██╗██╔══██╗██╔═══██╗╚══██╔══╝    
██║  ███╗██║   ██║██║  ██║██║   ██║   ██║       
██║   ██║██║   ██║██║  ██║██║   ██║   ██║       
╚██████╔╝╚██████╔╝██████╔╝╚██████╔╝   ██║       
 ╚═════╝  ╚═════╝ ╚═════╝  ╚═════╝    ╚═╝       
                                                  
     █████╗ ██████╗ ██╗  ██╗██╗     ██╗███████╗ 
    ██╔══██╗██╔══██╗██║ ██╔╝██║     ██║██╔════╝ 
    ███████║██████╔╝█████╔╝ ██║     ██║███████╗ 
    ██╔══██║██╔═══╝ ██╔═██╗ ██║     ██║╚════██║ 
    ██║  ██║██║     ██║  ██╗███████╗██║███████║ 
    ╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝╚══════╝ 
                                                  
██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗██████╗ 
██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗  ██████╔╝
██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝  ██╔══██╗
╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗██║  ██║
 ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝

```

**Sistema robusto de verificación de actualizaciones para aplicaciones Android publicadas en [Apklis](https://www.apklis.cu), diseñado para Godot 4.5+**

![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Android-brightgreen.svg)
![Version](https://img.shields.io/badge/version-2.0-orange.svg)

## 🎯 Novedades de la versión 2.0

- ✨ **Sistema de reintentos automático** con configuración flexible
- ✨ **Cache inteligente** de resultados (reduce peticiones innecesarias)
- ✨ **Múltiples formas de configuración** (manual, project.godot, JSON)
- ✨ **Validación exhaustiva** con códigos de error específicos
- ✨ **API asíncrona** con soporte para `await`
- ✨ **Logs mejorados** para debug y diagnóstico
- ✨ **Inicialización lazy** (sin problemas de timing)
- ✨ **100% compatible** con versión anterior

## 📋 Características

- ✅ **Verificación automática** de actualizaciones desde la API de Apklis
- ✅ **Sistema de reintentos** inteligente para conexiones inestables
- ✅ **Cache de resultados** (5 minutos por defecto, configurable)
- ✅ **Diálogo personalizable** para notificar al usuario
- ✅ **Sistema de señales** robusto para manejar eventos
- ✅ **Validación exhaustiva** de package names y respuestas API
- ✅ **Códigos de error específicos** para mejor debugging
- ✅ **Múltiples métodos de configuración**
- ✅ **API síncrona y asíncrona** (con soporte para `await`)
- ✅ **Sin dependencias externas** - solo código GDScript puro
- ✅ **Compatible con AutoLoad** para uso global
- ✅ **Ejemplos completos** de implementación

## 🚀 Inicio Rápido

### Instalación

1. Copia la carpeta `addons/apklis_update/` a tu proyecto
2. Ve a **Proyecto → Configuración del Proyecto → AutoLoad**
3. Agrega:
   - **Path:** `res://addons/apklis_update/ApklisUpdateChecker.gd`
   - **Node Name:** `ApklisUpdate`

### Uso Básico (3 líneas)

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    ApklisUpdate.update_available.connect(_on_update_available)
    ApklisUpdate.check_for_updates()

func _on_update_available(info: Dictionary):
    print("Nueva versión: ", info.latest_version_name)
```

## 📖 Guías de Uso

### Opción 1: Configuración Manual (Recomendada)

```gdscript
func _ready():
    # Configuración básica
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    
    # Configuración avanzada (opcional)
    ApklisUpdate.set_retry_config(3, 5.0)  # 3 reintentos, 5s entre ellos
    ApklisUpdate.set_timeout(30.0)         # Timeout de 30 segundos
    ApklisUpdate.set_cache_enabled(true)   # Habilitar cache
    ApklisUpdate.show_dialog_on_update = true
    
    # Conectar señales
    ApklisUpdate.update_available.connect(_on_update_available)
    ApklisUpdate.no_update_available.connect(_on_no_update)
    ApklisUpdate.update_check_failed.connect(_on_check_failed)
    ApklisUpdate.update_check_started.connect(_on_check_started)
    
    # Verificar
    ApklisUpdate.check_for_updates()
```

### Opción 2: Configuración desde project.godot

En `project.godot`:
```ini
[application]
config/apklis_package_name="cu.empresa.mijuego"
config/version_code=1
```

En tu código:
```gdscript
func _ready():
    if ApklisUpdate.configure_from_project_settings():
        ApklisUpdate.check_for_updates()
```

### Opción 3: Configuración desde JSON

Crea `res://apklis_config.json`:
```json
{
  "package_name": "cu.empresa.mijuego",
  "version_code": 1
}
```

En tu código:
```gdscript
func _ready():
    if ApklisUpdate.configure_from_json("res://apklis_config.json"):
        ApklisUpdate.check_for_updates()
```

### Opción 4: Uso Asíncrono (await)

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    
    var result = await ApklisUpdate.check_for_updates_async()
    
    if result.has("error"):
        print("Error: ", result.error)
    elif result.has_update:
        print("¡Actualización disponible!")
        print("Nueva versión: ", result.latest_version_name)
    else:
        print("Todo actualizado")
```

## 🔧 API Reference

### Métodos de Configuración

| Método | Descripción |
|--------|-------------|
| `configure(package_name, version_code)` | Configura el checker (forma recomendada) |
| `configure_from_project_settings()` | Lee config desde project.godot |
| `configure_from_json(path)` | Lee config desde archivo JSON |
| `set_retry_config(max, delay)` | Configura reintentos (default: 2, 3.0s) |
| `set_timeout(seconds)` | Establece timeout HTTP (default: 30s) |
| `set_cache_enabled(enabled)` | Habilita/deshabilita cache |
| `clear_cache()` | Limpia el cache manualmente |

### Métodos de Verificación

| Método | Descripción |
|--------|-------------|
| `check_for_updates(force_check)` | Verifica actualizaciones (ignora cache si force=true) |
| `check_for_updates_async()` | Versión asíncrona, retorna Dictionary |
| `cancel_check()` | Cancela verificación en curso |

### Métodos de Utilidad

| Método | Descripción |
|--------|-------------|
| `get_status()` | Retorna Dictionary con estado actual |
| `get_last_error_code()` | Retorna último ErrorCode |
| `get_last_error_string()` | Retorna descripción del último error |

### Señales

```gdscript
signal update_available(update_info: Dictionary)   # Hay actualización
signal no_update_available(current_info: Dictionary) # No hay actualización
signal update_check_failed(error: String)           # Error en verificación
signal update_check_started()                       # Inició verificación
signal configuration_changed()                      # Cambió configuración
```

### ErrorCode Enum

```gdscript
enum ErrorCode {
    NONE = 0,                  # Sin error
    NOT_CONFIGURED = 1,        # No está configurado
    NETWORK_ERROR = 2,         # Error de red
    HTTP_ERROR = 3,            # Error HTTP (500, 503, etc)
    JSON_PARSE_ERROR = 4,      # Error parseando JSON
    NO_APP_FOUND = 5,          # App no encontrada en Apklis
    NO_RELEASE_INFO = 6,       # No hay info de release
    TIMEOUT = 7,               # Timeout de conexión
    INVALID_PACKAGE_NAME = 8,  # Package name inválido
}
```

### Estructura update_info

```gdscript
{
    "app_name": String,              # Nombre de la app
    "package_name": String,          # Identificador del paquete
    "description": String,           # Descripción
    "current_version_code": int,     # Versión actual
    "latest_version_code": int,      # Última versión en Apklis
    "latest_version_name": String,   # Nombre de versión (ej: "1.2.0")
    "changelog": String,             # Lista de cambios
    "download_url": String,          # URL del APK
    "size": String,                  # Tamaño legible (ej: "50 MB")
    "icon": String,                  # URL del icono
    "rating": float,                 # Calificación 0-5
    "download_count": int,           # Número de descargas
    "check_timestamp": int,          # Unix timestamp de verificación
}
```

## 💡 Ejemplos de Uso

### Debug y Diagnóstico

```gdscript
func _input(event):
    if event.is_action_pressed("ui_text_completion_replace"):  # F5
        _show_debug_info()

func _show_debug_info():
    var status = ApklisUpdate.get_status()
    
    print("\n=== ApklisUpdate Debug ===")
    print("Configurado: ", status.is_configured)
    print("Verificando: ", status.is_checking)
    print("Package: ", status.package_name)
    print("Versión: ", status.version_code)
    print("Cache válido: ", status.cache_valid)
    print("Último error: ", ApklisUpdate.get_last_error_string())
    
    # Forzar verificación (ignora cache)
    ApklisUpdate.check_for_updates(true)
```

### Verificación Periódica

```gdscript
var update_timer: Timer

func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    
    # Verificar cada 6 horas
    update_timer = Timer.new()
    add_child(update_timer)
    update_timer.wait_time = 21600.0  # 6 horas
    update_timer.timeout.connect(_check_updates)
    update_timer.start()
    
    _check_updates()  # Primera verificación

func _check_updates():
    ApklisUpdate.check_for_updates(true)  # Forzar, ignorar cache
```

### Botón en Menú de Configuración

```gdscript
@onready var check_button = $CheckButton
@onready var status_label = $StatusLabel

func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    check_button.pressed.connect(_on_check_pressed)
    
    ApklisUpdate.update_available.connect(func(info):
        status_label.text = "¡Actualización disponible!"
    )
    ApklisUpdate.no_update_available.connect(func(info):
        status_label.text = "Estás en la última versión"
    )
    ApklisUpdate.update_check_failed.connect(func(error):
        status_label.text = "Error: " + error
    )

func _on_check_pressed():
    status_label.text = "Verificando..."
    ApklisUpdate.check_for_updates()
```

### Manejo Completo de Errores

```gdscript
func _ready():
    if not ApklisUpdate.configure("cu.empresa.mijuego", 1):
        push_error("No se pudo configurar ApklisUpdate")
        return
    
    ApklisUpdate.update_check_failed.connect(_on_check_failed)
    ApklisUpdate.check_for_updates()

func _on_check_failed(error: String):
    var error_code = ApklisUpdate.get_last_error_code()
    
    match error_code:
        ApklisUpdateChecker.ErrorCode.NOT_CONFIGURED:
            push_error("Sistema no configurado")
        ApklisUpdateChecker.ErrorCode.NETWORK_ERROR:
            print("Sin conexión, reintentando más tarde...")
            _schedule_retry()
        ApklisUpdateChecker.ErrorCode.NO_APP_FOUND:
            push_error("App no encontrada en Apklis")
        ApklisUpdateChecker.ErrorCode.INVALID_PACKAGE_NAME:
            push_error("Package name inválido")
        _:
            push_warning("Error: ", error)
```

Más ejemplos en [`examples/`](examples/)

## 🔍 Sistema de Cache

El cache reduce peticiones innecesarias a la API:

```gdscript
# Cache habilitado por defecto (5 minutos)
ApklisUpdate.use_cache = true

# Deshabilitar cache
ApklisUpdate.set_cache_enabled(false)

# Limpiar cache manualmente
ApklisUpdate.clear_cache()

# Forzar verificación ignorando cache
ApklisUpdate.check_for_updates(true)
```

**Cuándo se usa el cache:**
- Múltiples llamadas a `check_for_updates()` en menos de 5 minutos
- El cache se invalida automáticamente después de 5 minutos
- Se puede deshabilitar completamente si se prefiere

## 🛠️ Sistema de Reintentos

Configuración flexible para conexiones inestables:

```gdscript
# Configurar reintentos
ApklisUpdate.set_retry_config(
    3,     # Máximo 3 reintentos
    5.0    # 5 segundos entre cada intento
)

# Los siguientes errores activan reintentos:
# - Errores de red (NETWORK_ERROR)
# - Errores HTTP 500, 502, 503 (servidor)

# Estos errores NO reintentan (fallan inmediatamente):
# - HTTP 400, 403, 404 (errores del cliente)
# - Errores de parsing JSON
# - App no encontrada
```

## ⚙️ Configuración Android

### 1. Export Preset

En **Proyecto → Configuración de Exportación → Android**:
- **Package/Unique Name:** `cu.empresa.mijuego`
- **Version/Code:** `1` (incrementar en cada versión)
- **Version/Name:** `"1.0.0"`

### 2. Publicación en Apklis

- Registra tu cuenta en [Apklis](https://www.apklis.cu)
- Sube tu APK con el mismo `package_name`
- Incrementa el `version_code` en cada actualización

## 🧪 Testing

### Probar con app de ejemplo

```gdscript
# Prueba con la app oficial de Apklis
ApklisUpdate.configure("cu.uci.android.apklis", 1)
ApklisUpdate.check_for_updates()
```

### Simular versión antigua

```gdscript
# Fuerza detección de actualización
ApklisUpdate.configure("cu.empresa.mijuego", 1)  # Versión muy baja
ApklisUpdate.check_for_updates()
```

### Inspeccionar respuesta completa

```gdscript
ApklisUpdate.update_available.connect(func(info):
    print(JSON.stringify(info, "\t"))
)
```

## 🐛 Solución de Problemas

| Problema | Solución |
|----------|----------|
| "Not configured" | Llama a `configure()` antes de `check_for_updates()` |
| "HTTP error: 404" | Verifica que tu app esté en Apklis y el package_name sea correcto |
| "Network error" | Verifica conexión a internet y acceso a api.apklis.cu |
| "Invalid package name" | El formato debe ser `com.empresa.app` (lowercase, puntos) |
| No detecta versión | Usa `configure(package, version)` para establecerla manualmente |
| Cache no funciona | Verifica con `get_status()` si está habilitado |
| Reintentos no funcionan | Algunos errores no reintentan (400, 404, JSON parse) |

## 📊 Migración desde v1.x

La versión 2.0 es **100% compatible** con código anterior:

```gdscript
# v1.x - SIGUE FUNCIONANDO
ApklisUpdate.package_name = "cu.empresa.app"
ApklisUpdate.set_version_code(1)
ApklisUpdate.check_for_updates()

# v2.0 - NUEVO (recomendado)
ApklisUpdate.configure("cu.empresa.app", 1)
ApklisUpdate.check_for_updates()
```

**Nuevas características en v2.0:**
- Sistema de reintentos
- Cache de resultados
- Múltiples formas de configuración
- API asíncrona
- Validación exhaustiva
- Códigos de error específicos
- Mejor logging

## 📂 Estructura del Proyecto

```
godot-apklis-updater/
├── addons/
│   └── apklis_update/
│       ├── ApklisUpdateChecker.gd      # Script principal (v2.0)
│       ├── ApklisUpdateDialog.gd       # Diálogo personalizado
│       ├── apklis_update_dialog.tscn   # Escena del diálogo
│       ├── plugin.cfg                  # Config del plugin
│       └── plugin.gd                   # Script del plugin
├── examples/
│   ├── example_basic.gd                # Uso básico
│   ├── example_settings_button.gd      # Botón en ajustes
│   ├── example_periodic_check.gd       # Verificación periódica
│   ├── example_custom_dialog.gd        # Diálogo personalizado
│   ├── example_main_menu.gd            # Integración en menú
│   ├── example_manual_instance.gd      # Sin AutoLoad
│   └── README.md                       # Guía de ejemplos
├── README.md                           # Este archivo
├── QUICK_START.md                      # Guía rápida
├── API_REFERENCE.md                    # Referencia API completa
├── CHANGELOG.md                        # Historial de cambios
└── LICENSE                             # Licencia MIT
```

## 📚 Documentación Adicional

- [**QUICK_START.md**](QUICK_START.md) - Guía rápida de inicio
- [**API_REFERENCE.md**](API_REFERENCE.md) - Referencia completa de la API
- [**CHANGELOG.md**](CHANGELOG.md) - Historial de cambios
- [**examples/README.md**](examples/README.md) - Guía de ejemplos

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas!

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -am 'Agrega mejora'`)
4. Push (`git push origin feature/mejora`)
5. Abre un Pull Request

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para detalles.

## 🇨🇺 Acerca de Apklis

[Apklis](https://www.apklis.cu) es la tienda de aplicaciones oficial de Cuba, desarrollada por la Universidad de las Ciencias Informáticas (UCI). Este proyecto facilita la integración de actualizaciones para desarrolladores que publican en esta plataforma.

## 🙏 Agradecimientos

- Basado en [apklisupdate](https://github.com/Z17-CU/apklisupdate) para Android nativo
- Comunidad de Godot Cuba
- Todos los contribuidores

## 📞 Soporte

¿Necesitas ayuda?

- 📝 [Abre un Issue](../../issues)
- 💬 Únete a la comunidad de Godot Cuba
- 📖 Revisa la [documentación](API_REFERENCE.md)

---

**Desarrollado con ❤️ para la comunidad de desarrolladores de Godot en Cuba 🇨🇺**

**v2.0** - Sistema robusto, extensible y fácil de usar
