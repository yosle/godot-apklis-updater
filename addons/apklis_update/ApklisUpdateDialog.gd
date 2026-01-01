extends Control
class_name ApklisUpdateDialog

## Diálogo personalizado para mostrar información de actualización

signal update_accepted
signal update_declined

var update_info: Dictionary = {}

@onready var panel = $Panel
@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var version_label = $Panel/VBoxContainer/VersionLabel
@onready var changelog_label = $Panel/VBoxContainer/ScrollContainer/ChangelogLabel
@onready var size_label = $Panel/VBoxContainer/InfoContainer/SizeLabel
@onready var downloads_label = $Panel/VBoxContainer/InfoContainer/DownloadsLabel
@onready var rating_label = $Panel/VBoxContainer/InfoContainer/RatingLabel
@onready var update_button = $Panel/VBoxContainer/ButtonsContainer/UpdateButton
@onready var later_button = $Panel/VBoxContainer/ButtonsContainer/LaterButton

func _ready():
	if not is_inside_tree():
		return
	
	# Conectar señales de botones
	update_button.pressed.connect(_on_update_pressed)
	later_button.pressed.connect(_on_later_pressed)
	
	# Configurar con la información de actualización
	if not update_info.is_empty():
		_setup_dialog()

func setup(info: Dictionary) -> void:
	update_info = info
	if is_inside_tree():
		_setup_dialog()

func _setup_dialog() -> void:
	title_label.text = "Nueva versión disponible: " + update_info.get("app_name", "")
	version_label.text = "Versión %s (Build %d)" % [
		update_info.get("latest_version_name", ""),
		update_info.get("latest_version_code", 0)
	]
	
	changelog_label.text = update_info.get("changelog", "Sin descripción de cambios")
	size_label.text = "Tamaño: " + update_info.get("size", "Desconocido")
	downloads_label.text = "Descargas: " + str(update_info.get("download_count", 0))
	
	var rating = update_info.get("rating", 0.0)
	rating_label.text = "★ %.1f" % rating

func _on_update_pressed() -> void:
	update_accepted.emit()
	var pkg_name = update_info.get("package_name", "")
	if pkg_name != "":
		OS.shell_open("https://www.apklis.cu/application/" + pkg_name)
	queue_free()

func _on_later_pressed() -> void:
	update_declined.emit()
	queue_free()

## Método estático para crear y mostrar el diálogo fácilmente
static func show_dialog(parent: Node, info: Dictionary) -> ApklisUpdateDialog:
	var dialog_scene = preload("res://addons/apklis_update/apklis_update_dialog.tscn")
	if dialog_scene:
		var dialog = dialog_scene.instantiate()
		parent.add_child(dialog)
		dialog.setup(info)
		return dialog
	else:
		# Si no existe la escena, crear el diálogo programáticamente
		var dialog = _create_programmatic_dialog(parent, info)
		return dialog

static func _create_programmatic_dialog(parent: Node, info: Dictionary) -> ApklisUpdateDialog:
	var dialog = ApklisUpdateDialog.new()
	parent.add_child(dialog)
	
	# Crear UI programáticamente
	dialog.anchor_left = 0.0
	dialog.anchor_top = 0.0
	dialog.anchor_right = 1.0
	dialog.anchor_bottom = 1.0
	
	# Panel oscuro de fondo
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.anchor_left = 0.0
	background.anchor_top = 0.0
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	dialog.add_child(background)
	
	# Panel principal
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(400, 300)
	panel.position = Vector2(100, 100)
	dialog.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	# Título
	var title = Label.new()
	title.text = "Nueva versión disponible"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Versión
	var version = Label.new()
	version.text = "Versión %s" % info.get("latest_version_name", "")
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(version)
	
	# Changelog
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 150)
	vbox.add_child(scroll)
	
	var changelog = Label.new()
	changelog.text = info.get("changelog", "Sin descripción")
	changelog.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(changelog)
	
	# Botones
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)
	
	var update_btn = Button.new()
	update_btn.text = "Actualizar"
	update_btn.pressed.connect(func(): 
		OS.shell_open("https://www.apklis.cu/application/" + info.get("package_name", ""))
		dialog.queue_free()
	)
	hbox.add_child(update_btn)
	
	var later_btn = Button.new()
	later_btn.text = "Más tarde"
	later_btn.pressed.connect(func(): dialog.queue_free())
	hbox.add_child(later_btn)
	
	dialog.setup(info)
	return dialog
