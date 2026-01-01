# 🚀 Guía de Inicio Rápido - v2.0

**Tiempo estimado: 5 minutos**

## 📦 Instalación (2 minutos)

### Paso 1: Copiar archivos
```
tu_proyecto/
├── addons/
│   └── apklis_update/
│       ├── ApklisUpdateChecker.gd  ← Copiar esto
│       ├── ApklisUpdateDialog.gd
│       └── apklis_update_dialog.tscn
```

### Paso 2: Configurar AutoLoad
1. Abre tu proyecto en Godot
2. Ve a **Proyecto → Configuración del Proyecto → AutoLoad**
3. Click en **"+"**
4. Configura:
   - **Path:** `res://addons/apklis_update/ApklisUpdateChecker.gd`
   - **Node Name:** `ApklisUpdate`
   - **Enable:** ✓ (marcado)
5. Click **"Add"**

¡Listo! Ya puedes usar `ApklisUpdate` desde cualquier script.

---

## 🎯 Uso Básico (3 minutos)

### Opción 1: Código Mínimo (3 líneas)

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    ApklisUpdate.update_available.connect(_on_update)
    ApklisUpdate.check_for_updates()

func _on_update(info):
    print("Nueva versión: ", info.latest_version_name)
```

### Opción 2: Con Manejo de Errores (Recomendado)

```gdscript
func _ready():
    # Configurar
    if not ApklisUpdate.configure("cu.empresa.mijuego", 1):
        push_error("Package name inválido")
        return
    
    # Conectar señales
    ApklisUpdate.update_available.connect(_on_update_available)
    ApklisUpdate.update_check_failed.connect(_on_check_failed)
    
    # Verificar
    ApklisUpdate.check_for_updates()

func _on_update_available(info: Dictionary):
    print("¡Hay actualización!")
    # El diálogo se muestra automáticamente

func _on_check_failed(error: String):
    print("Error al verificar: ", error)
```

### Opción 3: Uso Asíncrono (await)

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    await _check_updates()

func _check_updates():
    var result = await ApklisUpdate.check_for_updates_async()
    
    if result.has("error"):
        print("Error: ", result.error)
    elif result.has_update:
        print("Nueva versión: ", result.latest_version_name)
    else:
        print("Todo actualizado")
```

---

## ⚙️ Configuración Avanzada (Opcional)

### Desde project.godot

**Paso 1:** Edita `project.godot` y agrega:
```ini
[application]
config/apklis_package_name="cu.empresa.mijuego"
config/version_code=1
```

**Paso 2:** En tu código:
```gdscript
func _ready():
    if ApklisUpdate.configure_from_project_settings():
        ApklisUpdate.check_for_updates()
```

### Desde archivo JSON

**Paso 1:** Crea `res://apklis_config.json`:
```json
{
  "package_name": "cu.empresa.mijuego",
  "version_code": 1
}
```

**Paso 2:** En tu código:
```gdscript
func _ready():
    if ApklisUpdate.configure_from_json("res://apklis_config.json"):
        ApklisUpdate.check_for_updates()
```

---

## 🎨 Personalización

### Desactivar diálogo automático

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    ApklisUpdate.show_dialog_on_update = false  # Desactivar
    
    ApklisUpdate.update_available.connect(func(info):
        # Muestra tu propio diálogo personalizado
        show_my_custom_dialog(info)
    )
    
    ApklisUpdate.check_for_updates()
```

### Configurar reintentos

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    
    # 3 reintentos, 5 segundos entre cada uno
    ApklisUpdate.set_retry_config(3, 5.0)
    
    ApklisUpdate.check_for_updates()
```

### Ajustar timeout

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    
    # Timeout de 45 segundos
    ApklisUpdate.set_timeout(45.0)
    
    ApklisUpdate.check_for_updates()
```

### Deshabilitar cache

```gdscript
func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    
    # Siempre verificar en la API
    ApklisUpdate.set_cache_enabled(false)
    
    ApklisUpdate.check_for_updates()
```

---

## 🎯 Casos de Uso Comunes

### 1. Verificar al iniciar el juego

```gdscript
# En tu escena de menú principal
func _ready():
    ApklisUpdate.configure("cu.empresa.mijuego", 1)
    ApklisUpdate.check_for_updates()
```

### 2. Botón "Buscar actualizaciones"

```gdscript
@onready var check_button = $CheckButton
@onready var status_label = $StatusLabel

func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    check_button.pressed.connect(_on_check_pressed)
    
    ApklisUpdate.update_check_started.connect(func():
        status_label.text = "Verificando..."
    )
    ApklisUpdate.update_available.connect(func(info):
        status_label.text = "¡Actualización disponible!"
    )
    ApklisUpdate.no_update_available.connect(func(info):
        status_label.text = "Estás actualizado"
    )

func _on_check_pressed():
    ApklisUpdate.check_for_updates(true)  # Forzar verificación
```

### 3. Verificación periódica (cada 24 horas)

```gdscript
const CHECK_INTERVAL = 86400  # 24 horas en segundos

func _ready():
    ApklisUpdate.configure("cu.empresa.app", 1)
    
    var last_check = _load_last_check_time()
    var now = Time.get_unix_time_from_system()
    
    if now - last_check >= CHECK_INTERVAL:
        ApklisUpdate.check_for_updates()
        _save_last_check_time(now)

func _load_last_check_time() -> int:
    var save_file = "user://last_update_check.save"
    if FileAccess.file_exists(save_file):
        var file = FileAccess.open(save_file, FileAccess.READ)
        var time = file.get_64()
        file.close()
        return time
    return 0

func _save_last_check_time(time: int):
    var file = FileAccess.open("user://last_update_check.save", FileAccess.WRITE)
    file.store_64(time)
    file.close()
```

---

## 🔍 Debug y Diagnóstico

### Ver estado completo

```gdscript
func _input(event):
    if event.is_action_pressed("ui_text_completion_replace"):  # F5
        var status = ApklisUpdate.get_status()
        
        print("\n=== Estado de ApklisUpdate ===")
        print("Configurado: ", status.is_configured)
        print("Verificando: ", status.is_checking)
        print("Package: ", status.package_name)
        print("Versión: ", status.version_code)
        print("Cache válido: ", status.cache_valid)
        print("Último error: ", ApklisUpdate.get_last_error_string())
        print("=============================\n")
```

### Forzar verificación (sin cache)

```gdscript
func _on_debug_button_pressed():
    ApklisUpdate.check_for_updates(true)  # Ignora cache
```

---

## 📋 Checklist

Antes de publicar tu juego, verifica:

- [ ] Has configurado el `package_name` correcto
- [ ] El `package_name` coincide con el de tu Export Preset
- [ ] Has incrementado el `version_code` respecto a la versión anterior
- [ ] Tu app está publicada en Apklis
- [ ] Has probado la verificación de actualizaciones
- [ ] Manejas los errores apropiadamente (opcional)
- [ ] Has configurado reintentos (opcional)

---

## 🧪 Testing

### Probar con app de ejemplo

```gdscript
# Usa la app oficial de Apklis para probar
ApklisUpdate.configure("cu.uci.android.apklis", 1)
ApklisUpdate.check_for_updates()
```

### Simular actualización disponible

```gdscript
# Usa un version_code muy bajo
ApklisUpdate.configure("cu.empresa.mijuego", 1)
ApklisUpdate.check_for_updates()
```

### Ver respuesta completa

```gdscript
ApklisUpdate.update_available.connect(func(info):
    print(JSON.stringify(info, "\t"))
)
```

---

## ❓ Problemas Comunes

| Problema | Solución |
|----------|----------|
| "Not configured" | Llama a `configure()` antes de `check_for_updates()` |
| "HTTP error: 404" | Verifica que tu app esté en Apklis |
| "Invalid package name" | El formato debe ser `com.empresa.app` |
| No muestra diálogo | Verifica `show_dialog_on_update = true` |
| Siempre dice "actualizado" | Verifica que el `version_code` sea correcto |

---

## 📚 Próximos Pasos

- Lee la [**API Reference**](API_REFERENCE.md) completa
- Revisa los [**Ejemplos**](examples/) avanzados
- Consulta el [**CHANGELOG**](CHANGELOG.md) para novedades
- Personaliza el diálogo editando `apklis_update_dialog.tscn`

---

## 🎉 ¡Listo!

Ya tienes un sistema robusto de actualizaciones en tu juego. Las características principales incluyen:

- ✅ Reintentos automáticos para conexiones inestables
- ✅ Cache inteligente (reduce peticiones)
- ✅ Validación exhaustiva
- ✅ Múltiples formas de configuración
- ✅ API asíncrona con await
- ✅ Logs detallados para debug

**¿Necesitas ayuda?** Revisa la documentación completa o abre un issue en GitHub.

---

**Desarrollado con ❤️ para Godot Cuba 🇨🇺**
