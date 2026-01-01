extends Control
## Ejemplo de uso ASÍNCRONO con await - v2.0
##
## Este ejemplo muestra cómo usar la nueva API asíncrona de v2.0
## para un flujo de ejecución más limpio y secuencial

@onready var check_button = $VBoxContainer/CheckButton
@onready var status_label = $VBoxContainer/StatusLabel
@onready var progress_bar = $VBoxContainer/ProgressBar
@onready var info_panel = $VBoxContainer/InfoPanel

func _ready():
	# Configurar
	if not ApklisUpdate.configure("cu.empresa.mijuego", 1):
		push_error("Configuración falló")
		return
	
	# Configuración opcional
	ApklisUpdate.set_retry_config(3, 5.0)
	ApklisUpdate.set_timeout(30.0)
	ApklisUpdate.show_dialog_on_update = false  # Manejar manualmente
	
	# Conectar botón
	check_button.pressed.connect(_on_check_button_pressed)
	
	# Ocultar elementos inicialmente
	if progress_bar:
		progress_bar.visible = false
	if info_panel:
		info_panel.visible = false
	
	# Verificar automáticamente al inicio
	_check_updates_async()

# ═══════════════════════════════════════════════════════════════
# MÉTODO ASÍNCRONO PRINCIPAL
# ═══════════════════════════════════════════════════════════════

func _check_updates_async():
	print("\n=== Iniciando verificación asíncrona ===")
	
	# Mostrar UI de carga
	_show_loading_ui()
	
	# Esperar resultado de la verificación
	var result = await ApklisUpdate.check_for_updates_async()
	
	# Ocultar UI de carga
	_hide_loading_ui()
	
	# Procesar resultado
	if result.is_empty():
		# No se pudo iniciar la verificación
		_show_error("No se pudo iniciar la verificación")
		return
	
	if result.has("error"):
		# Hubo un error
		_show_error(result.error)
		return
	
	if result.has_update:
		# Hay actualización disponible
		_show_update_info(result)
	else:
		# No hay actualización
		_show_no_update_info(result)
	
	print("=== Verificación completada ===\n")

# ═══════════════════════════════════════════════════════════════
# FLUJO SECUENCIAL CON MÚLTIPLES PASOS
# ═══════════════════════════════════════════════════════════════

func _complex_update_flow():
	"""
	Ejemplo de un flujo más complejo que solo es posible
	de manera limpia con la API asíncrona
	"""
	print("\n=== Flujo de actualización complejo ===")
	
	# Paso 1: Limpiar cache y verificar
	status_label.text = "Paso 1: Limpiando cache..."
	await get_tree().create_timer(0.5).timeout
	
	ApklisUpdate.clear_cache()
	
	# Paso 2: Primera verificación
	status_label.text = "Paso 2: Verificando actualizaciones..."
	var result = await ApklisUpdate.check_for_updates_async()
	
	if result.has("error"):
		status_label.text = "Error en verificación"
		return
	
	# Paso 3: Analizar resultado
	status_label.text = "Paso 3: Analizando resultado..."
	await get_tree().create_timer(0.5).timeout
	
	if result.has_update:
		# Paso 4: Mostrar información detallada
		status_label.text = "Paso 4: Preparando información..."
		await get_tree().create_timer(0.5).timeout
		
		_show_detailed_update_info(result)
		
		# Paso 5: Preguntar al usuario
		var should_update = await _ask_user_to_update(result)
		
		if should_update:
			# Paso 6: Abrir Apklis
			status_label.text = "Abriendo Apklis..."
			OS.shell_open("https://www.apklis.cu/application/" + result.package_name)
		else:
			status_label.text = "Actualización pospuesta"
	else:
		status_label.text = "Estás actualizado"
	
	print("=== Flujo completado ===\n")

# ═══════════════════════════════════════════════════════════════
# VERIFICACIÓN CON TIMEOUT PERSONALIZADO
# ═══════════════════════════════════════════════════════════════

func _check_with_custom_timeout(timeout_seconds: float):
	"""
	Ejemplo de verificación con timeout personalizado
	"""
	print("\n=== Verificación con timeout de %.1fs ===" % timeout_seconds)
	
	ApklisUpdate.set_timeout(timeout_seconds)
	
	var start_time = Time.get_ticks_msec()
	var result = await ApklisUpdate.check_for_updates_async()
	var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
	
	print("Tiempo transcurrido: %.2fs" % elapsed)
	
	if result.has("error"):
		print("Error: %s" % result.error)
	else:
		print("Verificación exitosa")

# ═══════════════════════════════════════════════════════════════
# VERIFICACIÓN MÚLTIPLE (BATCH)
# ═══════════════════════════════════════════════════════════════

func _check_multiple_apps():
	"""
	Ejemplo de cómo verificar múltiples apps secuencialmente
	"""
	var apps = [
		{"name": "Mi Juego", "package": "cu.empresa.mijuego", "version": 1},
		{"name": "Mi App", "package": "cu.empresa.miapp", "version": 2},
		{"name": "Otra App", "package": "cu.empresa.otra", "version": 3}
	]
	
	print("\n=== Verificando %d apps ===" % apps.size())
	
	for app in apps:
		status_label.text = "Verificando %s..." % app.name
		
		# Configurar para esta app
		if not ApklisUpdate.configure(app.package, app.version):
			print("Error configurando %s" % app.name)
			continue
		
		# Verificar
		var result = await ApklisUpdate.check_for_updates_async()
		
		# Mostrar resultado
		if result.has("error"):
			print("  %s: Error - %s" % [app.name, result.error])
		elif result.has_update:
			print("  %s: Actualización disponible (v%s)" % [
				app.name,
				result.latest_version_name
			])
		else:
			print("  %s: Actualizado" % app.name)
		
		# Esperar un poco entre verificaciones
		await get_tree().create_timer(1.0).timeout
	
	status_label.text = "Verificación completa"
	print("=== Verificación completa ===\n")

# ═══════════════════════════════════════════════════════════════
# UI HELPERS
# ═══════════════════════════════════════════════════════════════

func _show_loading_ui():
	if status_label:
		status_label.text = "Verificando actualizaciones..."
	if progress_bar:
		progress_bar.visible = true
		progress_bar.value = 0
		_animate_progress_bar()
	if check_button:
		check_button.disabled = true

func _hide_loading_ui():
	if progress_bar:
		progress_bar.visible = false
	if check_button:
		check_button.disabled = false

func _animate_progress_bar():
	if not progress_bar or not progress_bar.visible:
		return
	
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(progress_bar, "value", 100, 2.0)
	tween.tween_property(progress_bar, "value", 0, 0.0)

func _show_update_info(info: Dictionary):
	if status_label:
		status_label.text = "¡Nueva versión v%s disponible!" % info.latest_version_name
	
	if info_panel:
		info_panel.visible = true
		_populate_info_panel(info)
	
	print("\n✓ Actualización disponible:")
	print("  Versión: %s" % info.latest_version_name)
	print("  Tamaño: %s" % info.size)

func _show_no_update_info(info: Dictionary):
	if status_label:
		status_label.text = "Estás usando la última versión (v%s)" % info.latest_version_name
	
	if info_panel:
		info_panel.visible = false
	
	print("\n✓ No hay actualizaciones disponibles")

func _show_error(error: String):
	if status_label:
		status_label.text = "Error: %s" % ApklisUpdate.get_last_error_string()
	
	if info_panel:
		info_panel.visible = false
	
	print("\n✗ Error: %s" % error)
	print("  Código: %s" % ApklisUpdate.get_last_error_string())

func _show_detailed_update_info(info: Dictionary):
	print("\n╔════════════════════════════════════════╗")
	print("║   INFORMACIÓN DE ACTUALIZACIÓN         ║")
	print("╚════════════════════════════════════════╝")
	print("App:              %s" % info.app_name)
	print("Package:          %s" % info.package_name)
	print("Versión actual:   v%d" % info.current_version_code)
	print("Nueva versión:    v%d (%s)" % [
		info.latest_version_code,
		info.latest_version_name
	])
	print("Tamaño:           %s" % info.size)
	print("Rating:           %.1f/5.0" % info.rating)
	print("Descargas:        %d" % info.download_count)
	print("\nCambios:")
	print(info.changelog)
	print("═══════════════════════════════════════════\n")

func _populate_info_panel(info: Dictionary):
	# Implementa según tu UI
	pass

func _ask_user_to_update(info: Dictionary) -> bool:
	"""
	Muestra un diálogo y espera la decisión del usuario
	Retorna true si el usuario quiere actualizar
	"""
	var dialog = ConfirmationDialog.new()
	dialog.title = "Actualizar Ahora"
	dialog.dialog_text = """
Nueva versión %s disponible

Cambios:
%s

¿Deseas actualizar ahora?
	""" % [info.latest_version_name, info.changelog]
	
	add_child(dialog)
	dialog.popup_centered()
	
	# Esperar decisión del usuario
	var result = await dialog.confirmed
	var user_confirmed = result if result is bool else false
	
	dialog.queue_free()
	return user_confirmed

# ═══════════════════════════════════════════════════════════════
# CALLBACKS
# ═══════════════════════════════════════════════════════════════

func _on_check_button_pressed():
	# Verificación simple
	_check_updates_async()

func _input(event):
	# F5 - Verificación simple
	if event.is_action_pressed("ui_text_completion_replace"):
		_check_updates_async()
	
	# F6 - Flujo complejo
	if event.is_action_pressed("ui_text_completion_query"):
		_complex_update_flow()
	
	# F7 - Verificación con timeout corto
	if event.is_action_pressed("ui_text_completion_accept"):
		_check_with_custom_timeout(5.0)
	
	# F8 - Verificar múltiples apps
	if event.is_action_pressed("ui_graph_delete"):
		_check_multiple_apps()

# ═══════════════════════════════════════════════════════════════
# EJEMPLO: INTEGRACIÓN CON LOADING SCREEN
# ═══════════════════════════════════════════════════════════════

func example_with_loading_screen():
	"""
	Ejemplo de cómo integrar con una pantalla de carga
	"""
	# Mostrar loading screen
	var loading = preload("res://scenes/loading_screen.tscn").instantiate()
	add_child(loading)
	loading.set_text("Verificando actualizaciones...")
	
	# Verificar
	var result = await ApklisUpdate.check_for_updates_async()
	
	# Actualizar loading screen
	if result.has_update:
		loading.set_text("Nueva versión disponible!")
		await get_tree().create_timer(2.0).timeout
	
	# Quitar loading screen
	loading.queue_free()
	
	# Continuar con el juego
	if result.has_update:
		_show_update_dialog(result)

func _show_update_dialog(info: Dictionary):
	# Implementación del diálogo
	pass
