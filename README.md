# Godot Apklis Updater

Sistema de verificación de actualizaciones para aplicaciones Android publicadas en [Apklis](https://www.apklis.cu), diseñado para proyectos en Godot 4.5+ (Probablemente tambien funcione en versiones anteriores).

Este proyecto nació por una necesidad práctica: mientras desarrollaba mi primer juego, *Trisquellum*, necesitaba una forma confiable de consultar la API de Apklis y notificar al usuario cuando existiera una versión más reciente. Con el tiempo lo convertí en un addon reutilizable y configurable, pensado para integrarse como AutoLoad y usarse desde GDScript.

![Godot 4.5+](https://img.shields.io/badge/Godot-4.5+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Android-brightgreen.svg)

## Características

- **Verificación de actualizaciones** desde la API de Apklis.
- **Reintentos configurables** para conexiones inestables.
- **Cache de resultados** para evitar peticiones innecesarias.
- **Diálogo de actualización** personalizable.
- **Señales** para integrar el flujo en UI/lógica de juego.
- **Validación** de `package_name` y de respuestas de la API.
- **Códigos de error** para diagnóstico.
- **Configuración flexible** (manual, `project.godot`, JSON).
- **API síncrona y asíncrona** (con soporte para `await`).
- **Sin dependencias externas** (GDScript).

## Inicio Rápido

### Instalación

1. Copia la carpeta `addons/apklis_update/` a tu proyecto
2. Ve a **Proyecto → Configuración del Proyecto → AutoLoad**
3. Agrega:
   - **Path:** `res://addons/apklis_update/ApklisUpdateChecker.gd`
   - **Node Name:** `ApklisUpdate`

### Uso Básico (3 líneas)

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 42)
    ApklisUpdate.update_available.connect(_on_update_available)
    ApklisUpdate.check_for_updates()

func _on_update_available(info: Dictionary):
    print("Nueva versión: ", info.latest_version_name)
```

## Guías de Uso

### Opción 1: Configuración Manual (Recomendada)

```gdscript
func _ready():
    # Configuración básica
    ApklisUpdate.configure("cu.empresa.mijuego", 42)
    
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
config/version_code=42
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
  "version_code": 42
}
```

En tu código:
```gdscript
func _ready():
    if ApklisUpdate.configure_from_json("res://apklis_config.json"):
        ApklisUpdate.check_for_updates()
```

### Estructura update_info

```gdscript
{
    "app_name": String,              # Nombre de la app
    "package_name": String,          # Identificador del paquete
    "description": String,           # Descripción
    "current_version_code": int,     # Versión actual
    "latest_version_code": int,      # Última versión en Apklis
    "latest_version_name": String,   # Nombre de versión (ej: "x.y.z")
    "changelog": String,             # Lista de cambios
    "download_url": String,          # URL del APK
    "size": String,                  # Tamaño legible (ej: "50 MB")
    "icon": String,                  # URL del icono
    "rating": float,                 # Calificación 0-5
    "download_count": int,           # Número de descargas
    "check_timestamp": int,          # Unix timestamp de verificación
}
```

## Ejemplos de Uso

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
    ApklisUpdate.configure("cu.empresa.mijuego", 42)
    
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

### Manejo Completo de Errores

```gdscript
func _ready():
    if not ApklisUpdate.configure("cu.empresa.mijuego", 42):
        push_error("No se pudo configurar ApklisUpdate")
        return
    
    ApklisUpdate.update_check_failed.connect(_on_check_failed)
    ApklisUpdate.check_for_updates()

func _on_check_failed(error: String):
    var error_code = ApklisUpdate.get_last_error_code()
    
    match error_code:
        ApklisUpdate.ErrorCode.NOT_CONFIGURED:
            push_error("Sistema no configurado")
        ApklisUpdate.ErrorCode.NETWORK_ERROR:
            print("Sin conexión, reintentando más tarde...")
            _schedule_retry()
        ApklisUpdate.ErrorCode.NO_APP_FOUND:
            push_error("App no encontrada en Apklis")
        ApklisUpdate.ErrorCode.INVALID_PACKAGE_NAME:
            push_error("Package name inválido")
        _:
            push_warning("Error: ", error)
```

## Configuración Android

### 1. Export Preset

En **Proyecto → Configuración de Exportación → Android**:
- **Package/Unique Name:** `cu.empresa.mijuego`
- **Version/Code:** `42` (incrementar en cada publicación)
- **Version/Name:** `"x.y.z"`

### 2. Publicación en Apklis

- Registra tu cuenta en [Apklis](https://www.apklis.cu)
- Sube tu APK con el mismo `package_name`
- Incrementa el `version_code` en cada actualización

## Testing

### Probar con app de ejemplo

```gdscript
# Prueba con la app oficial de Apklis
ApklisUpdate.configure("cu.uci.android.apklis", 10)
ApklisUpdate.check_for_updates()
```

### Simular versión antigua

```gdscript
# Fuerza detección de actualización
ApklisUpdate.configure("cu.empresa.mijuego", 10)  # Version code intencionalmente bajo
ApklisUpdate.check_for_updates()
```

### Inspeccionar respuesta completa

```gdscript
ApklisUpdate.update_available.connect(func(info):
    print(JSON.stringify(info, "\t"))
)
```

## Solución de Problemas

| Problema | Solución |
|----------|----------|
| "Not configured" | Llama a `configure()` antes de `check_for_updates()` |
| "HTTP error: 404" | Verifica que tu app esté en Apklis y el package_name sea correcto |
| "Network error" | Verifica conexión a internet y acceso a api.apklis.cu |
| "Invalid package name" | El formato debe ser `com.empresa.app` (lowercase, puntos) |
| No detecta versión | Usa `configure(package, version)` para establecerla manualmente |
| Cache no funciona | Verifica con `get_status()` si está habilitado |
| Reintentos no funcionan | Algunos errores no reintentan (400, 404, JSON parse) |

## Estructura del Proyecto

```
godot-apklis-updater/
├── addons/
│   └── apklis_update/
│       ├── ApklisUpdateChecker.gd      # Script principal
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

## Documentación Adicional

- [**QUICK_START.md**](QUICK_START.md) - Guía rápida de inicio
- [**API_REFERENCE.md**](API_REFERENCE.md) - Referencia completa de la API
- [**CHANGELOG.md**](CHANGELOG.md) - Historial de cambios
- [**examples/README.md**](examples/README.md) - Guía de ejemplos

## Contribuciones

¡Las contribuciones son bienvenidas!

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/mejora`)
3. Commit tus cambios (`git commit -am 'Agrega mejora'`)
4. Push (`git push origin feature/mejora`)
5. Abre un Pull Request

Ver [CONTRIBUTING.md](CONTRIBUTING.md) para más detalles.

## Licencia

Este proyecto está bajo la Licencia MIT. Ver [LICENSE](LICENSE) para detalles.

## Soporte

¿Necesitas ayuda?

- [Abre un Issue](../../issues)
- Revisa la [documentación](API_REFERENCE.md)

---

Desarrollado a partir de una necesidad real durante el desarrollo de *Trisquellum*.
