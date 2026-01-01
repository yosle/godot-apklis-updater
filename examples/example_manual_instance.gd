# =============================================================================
# EJEMPLO 7: INSTANCIA MANUAL (SIN AUTOLOAD)
# =============================================================================

extends Node2D

var update_checker: ApklisUpdateChecker

func _ready():
	# Crear instancia del checker manualmente
	update_checker = ApklisUpdateChecker.new()
	add_child(update_checker)
	
	# Configurar propiedades
	update_checker.package_name = "cu.tu_empresa.tu_juego"
	update_checker.auto_check_on_ready = false  # No verificar automáticamente
	update_checker.show_dialog_on_update = true
	update_checker.set_version_code(1)
	
	# Conectar señales
	update_checker.update_available.connect(_on_update_available)
	update_checker.no_update_available.connect(_on_no_update)
	update_checker.update_check_failed.connect(_on_error)
	
	# Verificar solo cuando el usuario abra los ajustes
	# update_checker.check_for_updates()

func _on_settings_opened():
	# Verificar cuando el usuario abra el menú de ajustes
	update_checker.check_for_updates()

func _on_game_paused():
	# O verificar cuando el juego se pause
	update_checker.check_for_updates()

func _on_update_available(info: Dictionary):
	print("Nueva versión disponible: ", info.latest_version_name)

func _on_no_update(info: Dictionary):
	print("Todo actualizado")

func _on_error(error: String):
	print("Error: ", error)
