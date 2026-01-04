# =============================================================================
# EJEMPLO: DIÁLOGO PERSONALIZADO
# =============================================================================
# Este ejemplo muestra cómo crear tu propio diálogo de actualización
# con el diseño y funcionalidad que prefieras

extends Node2D

func _ready():
	# Configurar el checker
	ApklisUpdate.configure("cu.empresa.mijuego", 1)
	
	# Desactivar el diálogo automático básico
	ApklisUpdate.show_dialog_on_update = false
	
	# Conectar a nuestra función personalizada
	ApklisUpdate.update_available.connect(_show_custom_dialog)
	
	# Verificar actualizaciones
	ApklisUpdate.check_for_updates()

# =============================================================================
# OPCIÓN 1: DIÁLOGO PERSONALIZADO SIMPLE
# =============================================================================

func _show_custom_dialog(info: Dictionary):
	# Crear un panel personalizado simple
	var panel = PanelContainer.new()
	add_child(panel)
	
	# Centrar en pantalla
	panel.position = Vector2(
		(get_viewport_rect().size.x - 400) / 2,
		(get_viewport_rect().size.y - 300) / 2
	)
	panel.custom_minimum_size = Vector2(400, 300)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	# Margen interno
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	vbox.add_child(margin)
	
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 15)
	margin.add_child(content)
	
	# Título personalizado con el nombre de tu juego
	var title = Label.new()
	title.text = "¡Actualización Disponible!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	content.add_child(title)
	
	# Información de versión
	var version_info = Label.new()
	version_info.text = "Nueva versión: " + info.latest_version_name
	version_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(version_info)
	
	# Changelog
	var changelog_scroll = ScrollContainer.new()
	changelog_scroll.custom_minimum_size = Vector2(0, 120)
	content.add_child(changelog_scroll)
	
	var changelog = Label.new()
	changelog.text = "Novedades:\n" + info.changelog
	changelog.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	changelog_scroll.add_child(changelog)
	
	# Información adicional
	var size_label = Label.new()
	size_label.text = "Tamaño: " + info.size
	size_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(size_label)
	
	# Botones
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(button_container)
	
	# Botón de actualizar
	var update_btn = Button.new()
	update_btn.text = "Actualizar Ahora"
	update_btn.custom_minimum_size = Vector2(150, 40)
	update_btn.pressed.connect(func():
		_on_user_accepts(info.package_name)
		panel.queue_free()
	)
	button_container.add_child(update_btn)
	
	# Botón de más tarde
	var later_btn = Button.new()
	later_btn.text = "Más Tarde"
	later_btn.custom_minimum_size = Vector2(150, 40)
	later_btn.pressed.connect(func():
		_on_user_declines()
		panel.queue_free()
	)
	button_container.add_child(later_btn)

func _on_user_accepts(package_name: String):
	print("Usuario aceptó actualizar")
	OS.shell_open("https://www.apklis.cu/application/" + package_name)

func _on_user_declines():
	print("Usuario decidió actualizar más tarde")
	# Tal vez recordarle en 24 horas
	_schedule_reminder()

func _schedule_reminder():
	# Guardar que el usuario quiere que le recuerden
	var file = FileAccess.open("user://update_reminder.dat", FileAccess.WRITE)
	if file:
		file.store_64(Time.get_unix_time_from_system() + 86400)  # 24 horas
		file.close()
	print("Recordatorio programado para dentro de 24 horas")


# =============================================================================
# OPCIÓN 2: DIÁLOGO CON DISEÑO AVANZADO Y ANIMACIONES
# =============================================================================

func _show_animated_dialog(info: Dictionary):
	# Fondo oscuro semitransparente
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	add_child(overlay)
	
	# Animar entrada del fondo
	var tween = create_tween()
	tween.tween_property(overlay, "color", Color(0, 0, 0, 0.7), 0.3)
	
	# Panel principal
	var panel = PanelContainer.new()
	overlay.add_child(panel)
	
	# Centrar y escalar desde 0
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -200
	panel.offset_top = -150
	panel.offset_right = 200
	panel.offset_bottom = 150
	panel.scale = Vector2.ZERO
	
	# Animar entrada del panel
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Contenido del panel
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "🎉 ¡Nueva Versión! 🎉"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)
	
	var version = Label.new()
	version.text = info.latest_version_name
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_font_size_override("font_size", 20)
	vbox.add_child(version)
	
	# ... Agregar más contenido según necesites
	
	# Botones
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	var update_btn = Button.new()
	update_btn.text = "¡Descargar!"
	update_btn.pressed.connect(func():
		OS.shell_open("https://www.apklis.cu/application/" + info.package_name)
		# Animar salida
		var exit_tween = create_tween()
		exit_tween.tween_property(panel, "scale", Vector2.ZERO, 0.3)
		exit_tween.tween_property(overlay, "color:a", 0.0, 0.3)
		exit_tween.finished.connect(overlay.queue_free)
	)
	hbox.add_child(update_btn)
