extends Control
## Ejemplo de integración en menú principal v2.0
##
## Muestra cómo integrar la verificación de actualizaciones en un menú principal
## con las nuevas características de v2.0: reintentos, cache, y configuración flexible

@onready var start_button = $VBoxContainer/StartButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton
@onready var update_badge = $UpdateBadge  # Badge para indicar actualización disponible
@onready var status_label = $StatusLabel

var has_update_available := false

func _ready():
	# ═══════════════════════════════════════════════════════════
	# CONFIGURACIÓN v2.0 - Múltiples opciones
	# ═══════════════════════════════════════════════════════════
	
	# Opción 1: Configuración directa (RECOMENDADA)
	if not ApklisUpdate.configure("cu.empresa.mijuego", 1):
		push_error("Configuración falló")
		return
	
	# Opción 2: Desde project.godot (alternativa)
	# En project.godot agrega:
	# [application]
	# config/apklis_package_name="cu.empresa.mijuego"
	# config/version_code=1
	#
	# Luego usa:
	# if not ApklisUpdate.configure_from_project_settings():
	#     push_error("No se pudo configurar desde project settings")
	#     return
	
	# Opción 3: Desde JSON (alternativa)
	# if not ApklisUpdate.configure_from_json("res://config.json"):
	#     push_error("No se pudo leer config.json")
	#     return
	
	# ═══════════════════════════════════════════════════════════
	# CONFIGURACIÓN AVANZADA v2.0
	# ═══════════════════════════════════════════════════════════
	
	# Configurar reintentos (útil para conexiones inestables)
	ApklisUpdate.set_retry_config(3, 5.0)  # 3 reintentos, 5s entre ellos
	
	# Configurar timeout
	ApklisUpdate.set_timeout(30.0)  # 30 segundos
	
	# Habilitar cache (reduce peticiones)
	ApklisUpdate.set_cache_enabled(true)
	
	# No mostrar diálogo automático (lo manejaremos manualmente)
	ApklisUpdate.show_dialog_on_update = false
	
	# ═══════════════════════════════════════════════════════════
	# CONECTAR SEÑALES
	# ═══════════════════════════════════════════════════════════
	
	ApklisUpdate.update_check_started.connect(_on_check_started)
	ApklisUpdate.update_available.connect(_on_update_available)
	ApklisUpdate.no_update_available.connect(_on_no_update)
	ApklisUpdate.update_check_failed.connect(_on_check_failed)
	
	# Conectar botones
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Ocultar badge inicialmente
	if update_badge:
		update_badge.visible = false
	
	# ═══════════════════════════════════════════════════════════
	# VERIFICAR ACTUALIZACIONES
	# ═══════════════════════════════════════════════════════════
	
	# Verificar solo si no se ha verificado recientemente
	if _should_check_updates():
		ApklisUpdate.check_for_updates()
	else:
		if status_label:
			status_label.text = "Última verificación reciente"

# ═══════════════════════════════════════════════════════════════
# CALLBACKS DE ACTUALIZACIÓN
# ═══════════════════════════════════════════════════════════════

func _on_check_started():
	if status_label:
		status_label.text = "Verificando actualizaciones..."
	print("⟳ Verificando actualizaciones...")

func _on_update_available(info: Dictionary):
	has_update_available = true
	
	# Mostrar badge
	if update_badge:
		update_badge.visible = true
		update_badge.text = "¡Nueva versión!"
	
	if status_label:
		status_label.text = "Nueva versión v%s disponible" % info.latest_version_name
	
	print("✓ Actualización disponible: v%s" % info.latest_version_name)
	
	# Guardar que verificamos
	_save_last_check_time()
	
	# Mostrar notificación sutil (opcional)
	_show_update_notification(info)

func _on_no_update(info: Dictionary):
	has_update_available = false
	
	if status_label:
		status_label.text = "Todo actualizado"
	
	print("✓ No hay actualizaciones")
	
	# Guardar que verificamos
	_save_last_check_time()

func _on_check_failed(error: String):
	if status_label:
		status_label.text = ""
	
	# No molestar al usuario con errores de red
	# Solo log para debug
	print("✗ Error verificando: %s" % error)
	print("  Código: %s" % ApklisUpdate.get_last_error_string())

# ═══════════════════════════════════════════════════════════════
# CALLBACKS DE BOTONES
# ═══════════════════════════════════════════════════════════════

func _on_start_pressed():
	# Si hay actualización, preguntar antes de iniciar
	if has_update_available:
		_show_update_dialog_before_start()
	else:
		_start_game()

func _on_options_pressed():
	# Ir a opciones (aquí puedes tener un botón de "Buscar actualizaciones")
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_quit_pressed():
	get_tree().quit()

# ═══════════════════════════════════════════════════════════════
# UI PERSONALIZADA
# ═══════════════════════════════════════════════════════════════

func _show_update_notification(info: Dictionary):
	# Mostrar notificación sutil en lugar de diálogo intrusivo
	var notification = Panel.new()
	notification.size = Vector2(400, 100)
	notification.position = Vector2(
		(get_viewport().size.x - notification.size.x) / 2,
		get_viewport().size.y - 150
	)
	
	var label = Label.new()
	label.text = "Nueva versión %s disponible\nToca para actualizar" % info.latest_version_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = notification.size
	notification.add_child(label)
	
	add_child(notification)
	
	# Hacer clickeable
	var button = Button.new()
	button.size = notification.size
	button.flat = true
	button.pressed.connect(func():
		_show_full_update_dialog(info)
		notification.queue_free()
	)
	notification.add_child(button)
	
	# Auto-ocultar después de 5 segundos
	await get_tree().create_timer(5.0).timeout
	if notification and is_instance_valid(notification):
		var tween = create_tween()
		tween.tween_property(notification, "modulate:a", 0.0, 0.5)
		await tween.finished
		notification.queue_free()

func _show_update_dialog_before_start():
	var dialog = AcceptDialog.new()
	dialog.title = "Actualización disponible"
	dialog.dialog_text = "Hay una nueva versión disponible.\n¿Deseas actualizarla ahora o jugar con la versión actual?"
	
	dialog.ok_button_text = "Actualizar ahora"
	dialog.confirmed.connect(func():
		OS.shell_open("https://www.apklis.cu/application/" + ApklisUpdate.package_name)
	)
	
	dialog.add_cancel_button("Jugar ahora")
	dialog.canceled.connect(_start_game)
	
	add_child(dialog)
	dialog.popup_centered()

func _show_full_update_dialog(info: Dictionary):
	# Usar el diálogo de Apklis o crear uno personalizado
	ApklisUpdate.show_dialog_on_update = true
	ApklisUpdate.update_available.emit(info)

func _start_game():
	get_tree().change_scene_to_file("res://scenes/game.tscn")

# ═══════════════════════════════════════════════════════════════
# SISTEMA DE VERIFICACIÓN PERIÓDICA
# ═══════════════════════════════════════════════════════════════

const CHECK_INTERVAL_HOURS = 24

func _should_check_updates() -> bool:
	var last_check = _load_last_check_time()
	var current_time = Time.get_unix_time_from_system()
	var hours_passed = (current_time - last_check) / 3600.0
	
	return hours_passed >= CHECK_INTERVAL_HOURS

func _load_last_check_time() -> int:
	var save_path = "user://last_update_check.save"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			var time = file.get_64()
			file.close()
			return time
	return 0

func _save_last_check_time():
	var file = FileAccess.open("user://last_update_check.save", FileAccess.WRITE)
	if file:
		file.store_64(Time.get_unix_time_from_system())
		file.close()

# ═══════════════════════════════════════════════════════════════
# DEBUG
# ═══════════════════════════════════════════════════════════════

func _input(event):
	# F5 para forzar verificación (ignora cache y cooldown)
	if event.is_action_pressed("ui_text_completion_replace"):
		print("\n=== Verificación forzada ===")
		ApklisUpdate.clear_cache()
		ApklisUpdate.check_for_updates(true)
	
	# F6 para ver estado
	if event.is_action_pressed("ui_text_completion_query"):
		var status = ApklisUpdate.get_status()
		print("\n=== Estado de ApklisUpdate ===")
		print("Configurado: ", status.is_configured)
		print("Verificando: ", status.is_checking)
		print("Cache válido: ", status.cache_valid)
		print("Último error: ", ApklisUpdate.get_last_error_string())
