# =============================================================================
# EJEMPLO 3: VERIFICACIÓN PERIÓDICA (CADA 24 HORAS)
# =============================================================================

extends Node

const CHECK_INTERVAL_HOURS = 24
const SAVE_FILE_PATH = "user://last_update_check.dat"

func _ready():
	_check_if_should_verify()

func _check_if_should_verify():
	var last_check = _load_last_check_time()
	var current_time = Time.get_unix_time_from_system()
	var hours_passed = (current_time - last_check) / 3600.0
	
	print("Horas desde última verificación: ", hours_passed)
	
	if hours_passed >= CHECK_INTERVAL_HOURS or last_check == 0:
		print("Verificando actualizaciones...")
		ApklisUpdate.update_available.connect(_on_update_found)
		ApklisUpdate.check_for_updates()
		_save_last_check_time(current_time)
	else:
		print("No es necesario verificar aún. Próxima verificación en ", CHECK_INTERVAL_HOURS - hours_passed, " horas")

func _on_update_found(info: Dictionary):
	print("¡Nueva versión encontrada: ", info.latest_version_name, "!")

func _load_last_check_time() -> int:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var time = file.get_64()
			file.close()
			return time
	return 0

func _save_last_check_time(time: int):
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_64(time)
		file.close()
		print("Guardado tiempo de verificación: ", time)
