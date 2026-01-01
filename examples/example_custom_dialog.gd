# =============================================================================
# EJEMPLO 4: DIÁLOGO PERSONALIZADO
# =============================================================================

extends Node2D

func _ready():
	# Desactivar el diálogo automático
	ApklisUpdate.show_dialog_on_update = false
	
	# Conectar a nuestra función personalizada
	ApklisUpdate.update_available.connect(_show_custom_dialog)
	
	# Verificar actualizaciones
	ApklisUpdate.check_for_updates()

func _show_custom_dialog(info: Dictionary):
	# Opción 1: Usar el diálogo incluido en el addon
	var dialog = ApklisUpdateDialog.show_dialog(self, info)
	dialog.update_accepted.connect(_on_user_accepts)
	dialog.update_declined.connect(_on_user_declines)

func _on_user_accepts():
	print("Usuario aceptó actualizar")
	# Aquí puedes guardar una preferencia, mostrar un mensaje, etc.

func _on_user_declines():
	print("Usuario decidió actualizar más tarde")
	# Tal vez recordarle en 24 horas


# =============================================================================
# EJEMPLO 5: CREAR TU PROPIO DIÁLOGO COMPLETAMENTE PERSONALIZADO
# =============================================================================

func _show_my_custom_dialog(info: Dictionary):
	# Crear un panel personalizado
	var panel = PanelContainer.new()
	add_child(panel)
	
	panel.position = Vector2(200, 100)
	panel.custom_minimum_size = Vector2(400, 300)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Título personalizado con el nombre de tu juego
	var title = Label.new()
	title.text = "¡Actualización de " + info.app_name + "!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)
	
	# Información de versión
	var version_info = Label.new()
	version_info.text = "Nueva versión: " + info.latest_version_name
	version_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(version_info)
	
	# Changelog con formato
	var changelog = RichTextLabel.new()
	changelog.custom_minimum_size = Vector2(0, 150)
	changelog.bbcode_enabled = true
	changelog.text = "[b]Novedades:[/b]\n" + info.changelog
	vbox.add_child(changelog)
	
	# Botón de actualizar con tu estilo
	var update_btn = Button.new()
	update_btn.text = "🚀 Actualizar Ahora"
	update_btn.pressed.connect(func():
		OS.shell_open("https://www.apklis.cu/application/" + info.package_name)
		panel.queue_free()
	)
	vbox.add_child(update_btn)
	
	# Botón de recordar después
	var later_btn = Button.new()
	later_btn.text = "Recordar en 24 horas"
	later_btn.pressed.connect(func():
		_schedule_reminder()
		panel.queue_free()
	)
	vbox.add_child(later_btn)

func _schedule_reminder():
	# Guardar que el usuario quiere que le recuerden
	var file = FileAccess.open("user://update_reminder.dat", FileAccess.WRITE)
	if file:
		file.store_64(Time.get_unix_time_from_system() + 86400)  # 24 horas
		file.close()
	print("Recordatorio programado para dentro de 24 horas")
