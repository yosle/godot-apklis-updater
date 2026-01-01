# =============================================================================
# EJEMPLO 2: BOTÓN DE "BUSCAR ACTUALIZACIONES" EN AJUSTES
# =============================================================================

extends Control

@onready var check_button = $VBoxContainer/CheckUpdatesButton
@onready var status_label = $VBoxContainer/StatusLabel
@onready var version_label = $VBoxContainer/VersionLabel

func _ready():
	# Mostrar versión actual
	version_label.text = "Versión actual: 1.0.0 (Build 1)"
	
	# Conectar botón
	check_button.pressed.connect(_on_check_pressed)
	
	# Conectar señales del sistema de actualización
	ApklisUpdate.update_available.connect(_on_update_available)
	ApklisUpdate.no_update_available.connect(_on_no_update)
	ApklisUpdate.update_check_failed.connect(_on_error)

func _on_check_pressed():
	status_label.text = "Verificando actualizaciones..."
	check_button.disabled = true
	ApklisUpdate.check_for_updates()

func _on_update_available(info: Dictionary):
	status_label.text = "¡Actualización disponible: v" + info.latest_version_name + "!"
	status_label.add_theme_color_override("font_color", Color.GREEN)
	check_button.disabled = false

func _on_no_update(info: Dictionary):
	status_label.text = "Tu aplicación está actualizada"
	status_label.add_theme_color_override("font_color", Color.WHITE)
	check_button.disabled = false

func _on_error(error: String):
	status_label.text = "Error: " + error
	status_label.add_theme_color_override("font_color", Color.RED)
	check_button.disabled = false
