extends Node2D
## Ejemplo básico de uso del ApklisUpdateChecker v2.0
## 
## Este ejemplo muestra el uso más simple del sistema:
## 1. Configurar con package name y versión
## 2. Conectar señales
## 3. Verificar actualizaciones

func _ready():
	# ═══════════════════════════════════════════════════════════
	# CONFIGURACIÓN BÁSICA (v2.0 - Forma recomendada)
	# ═══════════════════════════════════════════════════════════
	
	# Método 1: Configuración directa (RECOMENDADO)
	if not ApklisUpdate.configure("cu.empresa.mijuego", 1):
		push_error("Package name inválido")
		return
	
	# Método 2: Configuración manual (v1.x - sigue funcionando)
	# ApklisUpdate.package_name = "cu.empresa.mijuego"
	# ApklisUpdate.set_version_code(1)
	
	# ═══════════════════════════════════════════════════════════
	# CONECTAR SEÑALES
	# ═══════════════════════════════════════════════════════════
	
	# Señal cuando HAY actualización disponible
	ApklisUpdate.update_available.connect(_on_update_available)
	
	# Señal cuando NO hay actualización
	ApklisUpdate.no_update_available.connect(_on_no_update_available)
	
	# Señal cuando hay un error
	ApklisUpdate.update_check_failed.connect(_on_update_check_failed)
	
	# Señal cuando inicia la verificación (v2.0)
	ApklisUpdate.update_check_started.connect(_on_update_check_started)
	
	# ═══════════════════════════════════════════════════════════
	# VERIFICAR ACTUALIZACIONES
	# ═══════════════════════════════════════════════════════════
	
	ApklisUpdate.check_for_updates()
	
	# El diálogo se mostrará automáticamente si hay actualización
	# (puedes desactivarlo con ApklisUpdate.show_dialog_on_update = false)

# ═══════════════════════════════════════════════════════════════
# CALLBACKS
# ═══════════════════════════════════════════════════════════════

func _on_update_check_started():
	print("\n⟳ Verificando actualizaciones...")

func _on_update_available(update_info: Dictionary):
	print("\n╔════════════════════════════════════════╗")
	print("║   ¡ACTUALIZACIÓN DISPONIBLE!           ║")
	print("╚════════════════════════════════════════╝")
	print("App: %s" % update_info.app_name)
	print("Tu versión: v%d" % update_info.current_version_code)
	print("Nueva versión: v%d (%s)" % [
		update_info.latest_version_code,
		update_info.latest_version_name
	])
	print("Tamaño: %s" % update_info.size)
	print("\nCambios:")
	print(update_info.changelog)
	print("═══════════════════════════════════════════\n")
	
	# El diálogo ya se muestra automáticamente
	# Pero puedes hacer otras cosas aquí:
	# - Guardar que hay actualización disponible
	# - Mostrar un badge en el menú
	# - Enviar analytics
	# - etc.

func _on_no_update_available(current_info: Dictionary):
	print("\n✓ Estás usando la última versión disponible")
	print("  Versión: v%d (%s)" % [
		current_info.latest_version_code,
		current_info.latest_version_name
	])
	print("  App: %s\n" % current_info.app_name)

func _on_update_check_failed(error: String):
	print("\n✗ Error verificando actualizaciones: %s" % error)
	
	# v2.0: Puedes obtener más información sobre el error
	var error_code = ApklisUpdate.get_last_error_code()
	var error_string = ApklisUpdate.get_last_error_string()
	
	print("  Código de error: %s" % error_string)
	
	# Manejo específico según el tipo de error
	match error_code:
		ApklisUpdateChecker.ErrorCode.NETWORK_ERROR:
			print("  → Verifica tu conexión a internet")
		ApklisUpdateChecker.ErrorCode.NO_APP_FOUND:
			print("  → La app no está publicada en Apklis")
		ApklisUpdateChecker.ErrorCode.INVALID_PACKAGE_NAME:
			print("  → El package name es inválido")
		ApklisUpdateChecker.ErrorCode.NOT_CONFIGURED:
			print("  → El sistema no está configurado")
		_:
			print("  → Error desconocido")
	
	print()

# ═══════════════════════════════════════════════════════════════
# FUNCIONES DE DEBUG (OPCIONAL)
# ═══════════════════════════════════════════════════════════════

func _input(event):
	# Presiona F5 para ver el estado del sistema
	if event.is_action_pressed("ui_text_completion_replace"):
		_show_debug_info()

func _show_debug_info():
	var status = ApklisUpdate.get_status()
	
	print("\n╔════════════════════════════════════════╗")
	print("║   DEBUG: Estado de ApklisUpdate        ║")
	print("╚════════════════════════════════════════╝")
	print("Configurado:    %s" % ("SÍ" if status.is_configured else "NO"))
	print("Verificando:    %s" % ("SÍ" if status.is_checking else "NO"))
	print("Package:        %s" % status.package_name)
	print("Versión:        %d" % status.version_code)
	print("Cache válido:   %s" % ("SÍ" if status.cache_valid else "NO"))
	print("Reintentos:     %d" % status.retry_count)
	print("Último error:   %s" % ApklisUpdate.get_last_error_string())
	print("═══════════════════════════════════════════\n")
