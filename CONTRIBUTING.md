# 🤝 Guía de Contribución

¡Gracias por tu interés en contribuir a Godot Apklis Updater! Este documento te guiará a través del proceso de contribución.

## 📋 Tabla de Contenidos

- [Código de Conducta](#código-de-conducta)
- [¿Cómo puedo contribuir?](#cómo-puedo-contribuir)
- [Proceso de Desarrollo](#proceso-de-desarrollo)
- [Guías de Estilo](#guías-de-estilo)
- [Reportar Bugs](#reportar-bugs)
- [Sugerir Mejoras](#sugerir-mejoras)

## Código de Conducta

Este proyecto y todos los participantes están regidos por un código de conducta. Al participar, se espera que mantengas este código. Por favor reporta comportamiento inaceptable.

## ¿Cómo puedo contribuir?

Hay muchas formas de contribuir:

### 🐛 Reportar Bugs

Los bugs son rastreados como [GitHub issues](../../issues). Antes de reportar:

1. **Busca si ya existe** - Verifica que el bug no haya sido reportado
2. **Usa un título claro** - "Error al verificar actualizaciones con package_name vacío"
3. **Describe el problema** - Pasos para reproducir, comportamiento esperado vs actual
4. **Incluye información del entorno** - Versión de Godot, Android, etc.

**Template para reportar bugs:**

```markdown
## Descripción
Breve descripción del problema

## Pasos para Reproducir
1. Ir a '...'
2. Hacer click en '...'
3. Ver error

## Comportamiento Esperado
Lo que debería pasar

## Comportamiento Actual
Lo que realmente pasa

## Entorno
- Godot: 4.x.x
- Android: X.X
- Versión del addon: X.X.X

## Información Adicional
Logs, capturas de pantalla, etc.
```

### 💡 Sugerir Mejoras

Las mejoras también se rastrean como [GitHub issues](../../issues). Para sugerir:

1. **Título descriptivo** - "Agregar soporte para descargas automáticas"
2. **Explica el caso de uso** - ¿Por qué sería útil?
3. **Describe la solución** - ¿Cómo funcionaría?

**Template para mejoras:**

```markdown
## Problema que Resuelve
Descripción del problema o necesidad

## Solución Propuesta
Cómo debería funcionar

## Alternativas Consideradas
Otras formas de resolver esto

## Información Adicional
Mockups, ejemplos, etc.
```

### 📝 Mejorar Documentación

- Corregir errores tipográficos
- Agregar más ejemplos
- Mejorar explicaciones
- Traducir documentación

### 💻 Contribuir Código

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/amazing-feature`)
3. Haz commit de tus cambios (`git commit -m 'Add amazing feature'`)
4. Push a la rama (`git push origin feature/amazing-feature`)
5. Abre un Pull Request

## Proceso de Desarrollo

### Configurar el Entorno

1. **Fork y clona el repositorio:**
   ```bash
   git clone https://github.com/tu-usuario/godot-apklis-updater.git
   cd godot-apklis-updater
   ```

2. **Crea un proyecto de Godot de prueba:**
   - Copia `addons/` a tu proyecto de prueba
   - Habilita el plugin

3. **Crea una rama para tu feature:**
   ```bash
   git checkout -b feature/mi-nueva-feature
   ```

### Haciendo Cambios

1. **Escribe código claro:**
   - Usa nombres descriptivos de variables
   - Comenta código complejo
   - Sigue las convenciones de GDScript

2. **Prueba tus cambios:**
   - Prueba con diferentes versiones de Godot
   - Prueba con apps reales de Apklis
   - Verifica que no rompas funcionalidad existente

3. **Actualiza la documentación:**
   - Si agregas features, actualiza README.md
   - Agrega ejemplos si es apropiado
   - Actualiza API_REFERENCE.md si cambias la API

4. **Actualiza el CHANGELOG:**
   ```markdown
   ## [Unreleased]
   ### Added
   - Tu nueva característica
   ```

## Guías de Estilo

### GDScript

```gdscript
# ✅ Bueno: Nombres descriptivos, documentación
## Verifica si hay actualizaciones disponibles
func check_for_updates(custom_package_name: String = "") -> void:
    var pkg_name = custom_package_name if custom_package_name != "" else package_name
    
    if pkg_name == "":
        push_error("ApklisUpdateChecker: No se especificó el nombre del paquete")
        return

# ❌ Malo: Sin documentación, nombres crípticos
func chk(p: String = "") -> void:
    var n = p if p != "" else pn
    if n == "":
        push_error("Error")
```

### Convenciones de Código

1. **Nombres de variables:**
   - `snake_case` para variables y funciones
   - `PascalCase` para clases
   - `UPPER_CASE` para constantes

2. **Indentación:**
   - Usa tabs (configuración por defecto de Godot)
   - Mantén consistencia

3. **Comentarios:**
   - Usa `##` para documentación de funciones
   - Usa `#` para comentarios internos
   - Escribe en español o inglés consistentemente

4. **Señales:**
   - Nombra señales en presente: `update_available` no `update_was_found`
   - Documenta los parámetros de la señal

### Git Commits

Usa mensajes descriptivos:

```bash
# ✅ Bueno
git commit -m "Add support for custom update dialogs"
git commit -m "Fix crash when package_name is empty"
git commit -m "Update README with new examples"

# ❌ Malo
git commit -m "fix"
git commit -m "update"
git commit -m "asdf"
```

**Formato recomendado:**

```
[Tipo] Descripción breve

Explicación más detallada si es necesario.
Puede ser de múltiples líneas.

- Punto relevante 1
- Punto relevante 2
```

**Tipos comunes:**
- `[Feature]` - Nueva característica
- `[Fix]` - Corrección de bug
- `[Docs]` - Cambios en documentación
- `[Refactor]` - Refactorización de código
- `[Test]` - Agregar o modificar tests
- `[Style]` - Cambios de formato, sin cambios funcionales

## Pull Request Process

1. **Verifica que tu PR:**
   - Compila sin errores
   - No rompe funcionalidad existente
   - Incluye documentación si es necesario
   - Actualiza el CHANGELOG

2. **Completa el template de PR:**
   - Descripción clara de los cambios
   - Referencia a issues relacionados
   - Capturas si es relevante

3. **Espera revisión:**
   - Responde a comentarios constructivamente
   - Haz cambios solicitados
   - Mantén la rama actualizada

**Template de Pull Request:**

```markdown
## Descripción
Breve descripción de los cambios

## Tipo de Cambio
- [ ] Bug fix (cambio que corrige un problema)
- [ ] Nueva característica (cambio que agrega funcionalidad)
- [ ] Breaking change (fix o feature que causaría problemas con versiones anteriores)
- [ ] Documentación

## ¿Cómo se ha probado?
Describe las pruebas realizadas

## Checklist
- [ ] Mi código sigue las guías de estilo
- [ ] He revisado mi propio código
- [ ] He comentado áreas complejas
- [ ] He actualizado la documentación
- [ ] Mis cambios no generan nuevas advertencias
- [ ] He actualizado el CHANGELOG
```

## Testing

Aunque no tenemos tests automatizados aún, asegúrate de probar:

1. **Casos comunes:**
   - Verificación exitosa con actualización disponible
   - Verificación exitosa sin actualización
   - Manejo de errores de red

2. **Casos extremos:**
   - Package_name vacío
   - App no publicada en Apklis
   - Sin conexión a internet
   - Respuestas inesperadas de la API

3. **Diferentes entornos:**
   - Godot 4.0, 4.1, 4.2+
   - Android 8, 10, 12+
   - Diferentes versiones de la app

## Versionado

Seguimos [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH`
- Ejemplo: `1.2.3`

**Cuándo incrementar:**
- **MAJOR** - Cambios incompatibles en la API
- **MINOR** - Nueva funcionalidad compatible
- **PATCH** - Correcciones de bugs

## Licencia

Al contribuir, aceptas que tus contribuciones sean licenciadas bajo la licencia MIT del proyecto.

## Recursos

- [Documentación de Godot](https://docs.godotengine.org/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [API de Apklis](https://api.apklis.cu/)
- [Semantic Versioning](https://semver.org/)

## Preguntas

¿Tienes preguntas? Puedes:
- Abrir un [GitHub Issue](../../issues)
- Contactar a los mantenedores

---

**¡Gracias por contribuir! 🎉**

Tu tiempo y esfuerzo ayudan a hacer este proyecto mejor para toda la comunidad de desarrolladores de Godot en Cuba. 🇨🇺
