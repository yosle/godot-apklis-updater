# 📚 Guía de Ejemplos - v2.0

Esta carpeta contiene ejemplos completos y funcionales de cómo usar el **Apklis Update Checker v2.0** en diferentes escenarios.

## 📑 Índice de Ejemplos

### 🎯 Ejemplos Básicos

1. **[example_basic.gd](example_basic.gd)** - Uso más simple
   - Configuración básica
   - Conectar señales
   - Verificación simple
   - Debug básico

2. **[example_async.gd](example_async.gd)** ⭐ NUEVO v2.0
   - Uso asíncrono con `await`
   - Flujos secuenciales complejos
   - Timeout personalizado
   - Verificación de múltiples apps

### 🎨 Ejemplos de Integración

3. **[example_main_menu.gd](example_main_menu.gd)** - Integración en menú
   - Badge de actualización disponible
   - Verificación periódica (24 horas)
   - UI personalizada
   - Notificaciones sutiles

4. **[example_settings_button.gd](example_settings_button.gd)** - Botón en ajustes
   - Botón "Buscar actualizaciones"
   - Estados de UI (verificando, encontrado, error)
   - Feedback visual

5. **[example_periodic_check.gd](example_periodic_check.gd)** - Verificación automática
   - Timer de 6 horas
   - Persistencia entre sesiones
   - Verificación en background

### 🔧 Ejemplos Avanzados

6. **[example_custom_dialog.gd](example_custom_dialog.gd)** - Diálogo personalizado
   - Crear diálogo propio
   - Estilo personalizado
   - Animaciones

7. **[example_manual_instance.gd](example_manual_instance.gd)** - Sin AutoLoad
   - Instancia manual del checker
   - Múltiples checkers
   - Casos de uso especiales

---

## 🚀 Cómo Usar los Ejemplos

### Método 1: Copiar y Adaptar

1. Abre el ejemplo que te interesa
2. Copia el código a tu proyecto
3. Adapta los nombres de paquete y versiones
4. Ajusta según tus necesidades

### Método 2: Ejecutar Directamente

1. Copia el ejemplo a tu proyecto
2. Crea una escena con un Node que use el script
3. Ejecuta y observa los logs en la consola

---

## 📖 Guía por Ejemplo

### 1. example_basic.gd

**Cuándo usar:**
- Primer contacto con el sistema
- Necesitas algo simple y rápido
- Solo verificar al inicio del juego

**Características v2.0:**
- ✅ Usa `configure()` (nueva forma recomendada)
- ✅ Muestra códigos de error específicos
- ✅ Debug con `get_status()`

**Código clave:**
```gdscript
# Configurar (v2.0)
if not ApklisUpdate.configure("cu.empresa.app", 1):
    return

# Conectar señales
ApklisUpdate.update_available.connect(_on_update)
ApklisUpdate.check_for_updates()
```

---

### 2. example_async.gd ⭐ NUEVO

**Cuándo usar:**
- Necesitas esperar el resultado antes de continuar
- Flujos complejos con múltiples pasos
- Integración con loading screens
- Verificación de múltiples apps

**Características v2.0:**
- ✅ API completamente asíncrona
- ✅ Uso de `await` para flujo limpio
- ✅ Timeout personalizado
- ✅ Verificación batch de múltiples apps

**Código clave:**
```gdscript
func _check_updates():
    # Esperar resultado
    var result = await ApklisUpdate.check_for_updates_async()
    
    # Procesar
    if result.has("error"):
        print("Error: ", result.error)
    elif result.has_update:
        print("¡Actualización!")
    else:
        print("Actualizado")
```

**Ventajas sobre señales:**
```gdscript
# Con señales (v1.x) - callbacks anidados
ApklisUpdate.update_available.connect(func(info):
    _step1(info)
    _step2(info)
    _step3(info)
)

# Con await (v2.0) - flujo secuencial limpio
var result = await ApklisUpdate.check_for_updates_async()
_step1(result)
await _step2(result)
await _step3(result)
```

---

### 3. example_main_menu.gd

**Cuándo usar:**
- Integración en menú principal
- Mostrar badge de actualización
- No molestar al usuario con diálogos intrusivos

**Características v2.0:**
- ✅ Cache para verificaciones rápidas
- ✅ Reintentos para conexiones inestables
- ✅ Verificación periódica (24 horas)
- ✅ Múltiples formas de configuración

**Código clave:**
```gdscript
func _ready():
    # Configurar con reintentos
    ApklisUpdate.configure("cu.empresa.app", 1)
    ApklisUpdate.set_retry_config(3, 5.0)
    ApklisUpdate.show_dialog_on_update = false
    
    # Verificar solo si pasaron 24 horas
    if _should_check_updates():
        ApklisUpdate.check_for_updates()
```

---

### 4. example_settings_button.gd

**Cuándo usar:**
- Botón "Buscar actualizaciones" en opciones
- Usuario verifica manualmente
- Feedback visual durante verificación

**Características v2.0:**
- ✅ Forzar verificación (ignora cache)
- ✅ Estados de UI claros
- ✅ Manejo de errores visual

**Código clave:**
```gdscript
func _on_check_pressed():
    status_label.text = "Verificando..."
    # Forzar verificación (ignora cache)
    ApklisUpdate.check_for_updates(true)
```

---

### 5. example_periodic_check.gd

**Cuándo usar:**
- Verificación automática en background
- No molestar al usuario
- Mantener app siempre actualizada

**Características v2.0:**
- ✅ Cache reduce peticiones innecesarias
- ✅ Timer configurable
- ✅ Persistencia entre sesiones

**Código clave:**
```gdscript
func _ready():
    # Timer de 6 horas
    var timer = Timer.new()
    timer.wait_time = 21600.0
    timer.timeout.connect(_check_updates)
    timer.start()
```

---

### 6. example_custom_dialog.gd

**Cuándo usar:**
- Quieres que el diálogo haga match con tu UI
- Necesitas animaciones especiales
- Agregar funcionalidad extra al diálogo

**Características v2.0:**
- ✅ Desactivar diálogo automático
- ✅ Crear diálogo completamente personalizado
- ✅ Manejar eventos a tu manera

**Código clave:**
```gdscript
ApklisUpdate.show_dialog_on_update = false
ApklisUpdate.update_available.connect(func(info):
    var my_dialog = MyCustomDialog.new()
    my_dialog.setup(info)
    add_child(my_dialog)
)
```

---

### 7. example_manual_instance.gd

**Cuándo usar:**
- No quieres usar AutoLoad
- Necesitas múltiples instancias
- Control total sobre el lifecycle

**Características v2.0:**
- ✅ Instanciar manualmente el checker
- ✅ Múltiples checkers independientes
- ✅ Liberar recursos cuando no se necesitan

**Código clave:**
```gdscript
var checker = ApklisUpdateChecker.new()
add_child(checker)
checker.configure("cu.empresa.app", 1)
checker.check_for_updates()
```

---

## 🆕 Novedades en v2.0

### Características Nuevas en Ejemplos

#### 1. Configuración Simplificada
```gdscript
# v1.x
ApklisUpdate.package_name = "cu.empresa.app"
ApklisUpdate.set_version_code(1)

# v2.0 - Más limpio
ApklisUpdate.configure("cu.empresa.app", 1)
```

#### 2. Sistema de Reintentos
```gdscript
# Configurar reintentos para conexiones inestables
ApklisUpdate.set_retry_config(3, 5.0)
```

#### 3. Cache Inteligente
```gdscript
# Primera llamada - consulta API
ApklisUpdate.check_for_updates()

# Segunda llamada (< 5 min) - usa cache
ApklisUpdate.check_for_updates()

# Forzar verificación - ignora cache
ApklisUpdate.check_for_updates(true)
```

#### 4. API Asíncrona
```gdscript
# Esperar resultado
var result = await ApklisUpdate.check_for_updates_async()

# Procesar
if result.has_update:
    show_dialog(result)
```

#### 5. Manejo de Errores Mejorado
```gdscript
ApklisUpdate.update_check_failed.connect(func(error):
    var code = ApklisUpdate.get_last_error_code()
    match code:
        ApklisUpdateChecker.ErrorCode.NETWORK_ERROR:
            print("Sin conexión")
        ApklisUpdateChecker.ErrorCode.NO_APP_FOUND:
            print("App no en Apklis")
)
```

#### 6. Debug Mejorado
```gdscript
var status = ApklisUpdate.get_status()
print("Configurado: ", status.is_configured)
print("Verificando: ", status.is_checking)
print("Cache válido: ", status.cache_valid)
```

---

## 🎯 Tabla de Decisión

**¿Qué ejemplo usar según tu caso?**

| Necesidad | Ejemplo Recomendado |
|-----------|---------------------|
| Algo simple y rápido | `example_basic.gd` |
| Flujos complejos con pasos | `example_async.gd` ⭐ |
| Integración en menú | `example_main_menu.gd` |
| Botón en ajustes | `example_settings_button.gd` |
| Verificación automática | `example_periodic_check.gd` |
| UI personalizada | `example_custom_dialog.gd` |
| Sin AutoLoad | `example_manual_instance.gd` |

---

## 💡 Tips de Uso

### 1. Empezar Simple
Comienza con `example_basic.gd` y ve agregando complejidad según necesites.

### 2. Usar Await para Flujos Complejos
Si necesitas varios pasos secuenciales, usa `example_async.gd`:
```gdscript
# Paso 1
var result = await ApklisUpdate.check_for_updates_async()

# Paso 2
if result.has_update:
    await show_dialog(result)

# Paso 3
start_game()
```

### 3. Cache para Mejor UX
No desactives el cache a menos que tengas una buena razón:
```gdscript
# ✅ Bueno - usa cache (rápido)
ApklisUpdate.check_for_updates()

# ⚠️ Solo si necesitas dato fresco
ApklisUpdate.check_for_updates(true)
```

### 4. Reintentos para Conexiones Inestables
Si tu audiencia tiene conexión inestable:
```gdscript
ApklisUpdate.set_retry_config(5, 10.0)  # 5 reintentos, 10s
```

### 5. No Molestar al Usuario
Los errores de red son comunes, no los muestres:
```gdscript
ApklisUpdate.update_check_failed.connect(func(error):
    # Log silencioso, no molestar al usuario
    print("Error: ", error)
)
```

---

## 🐛 Debug

Todos los ejemplos incluyen teclas de debug:

- **F5**: Forzar verificación (ignora cache)
- **F6**: Mostrar estado del sistema
- **F7**: Verificación con timeout corto
- **F8**: Casos especiales (según ejemplo)

---

## 📞 ¿Necesitas Ayuda?

- 📖 Lee la [API Reference completa](../API_REFERENCE.md)
- 🚀 Consulta la [Guía Rápida](../QUICK_START.md)
- 📝 Revisa el [README](../README.md)
- 💬 Abre un Issue en GitHub

---

## ✨ Contribuir

¿Tienes un caso de uso interesante? ¡Compártelo!

1. Crea un nuevo ejemplo
2. Documéntalo bien
3. Abre un Pull Request

---

**Desarrollado con ❤️ para Godot Cuba 🇨🇺**

**v2.0** - Ejemplos actualizados con las nuevas características
