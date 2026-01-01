@tool
extends EditorPlugin

func _enter_tree():
	# Agregar el AutoLoad automáticamente
	add_autoload_singleton("ApklisUpdate", "res://addons/apklis_update/ApklisUpdateChecker.gd")
	print("✅ Apklis Update Checker habilitado")
	print("   Puedes usar ApklisUpdate globalmente en tu proyecto")

func _exit_tree():
	# Remover el AutoLoad
	remove_autoload_singleton("ApklisUpdate")
	print("❌ Apklis Update Checker deshabilitado")

func _get_plugin_name():
	return "Apklis Update Checker"

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("ResourcePreloader", "EditorIcons")
