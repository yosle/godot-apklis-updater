extends Node
class_name ApklisUpdateChecker

## Sistema robusto de verificación de actualizaciones para Apklis
## 
## Características:
## - Inicialización lazy (se configura cuando sea necesario)
## - Validación exhaustiva
## - Sistema de retry automático
## - Cache de resultados
## - Múltiples formas de configuración
## 
## Uso básico:
##   ApklisUpdate.configure("com.my.app", 1)
##   ApklisUpdate.check_for_updates()
##
## Uso avanzado:
##   ApklisUpdate.configure_from_project_settings()
##   ApklisUpdate.set_retry_config(3, 5.0)
##   ApklisUpdate.check_for_updates()

#region Signals
signal update_available(update_info: Dictionary)
signal no_update_available(current_info: Dictionary)
signal update_check_failed(error: String)
signal update_check_started()
signal configuration_changed()
#endregion

#region Constants
const APKLIS_API_URL = "https://api.apklis.cu/v1/application/"
const DEFAULT_TIMEOUT = 30.0
const DEFAULT_MAX_RETRIES = 2
const DEFAULT_RETRY_DELAY = 3.0
const CACHE_DURATION = 300.0  # 5 minutos en segundos

## Códigos de error personalizados
enum ErrorCode {
	NONE = 0,
	NOT_CONFIGURED = 1,
	NETWORK_ERROR = 2,
	HTTP_ERROR = 3,
	JSON_PARSE_ERROR = 4,
	NO_APP_FOUND = 5,
	NO_RELEASE_INFO = 6,
	TIMEOUT = 7,
	INVALID_PACKAGE_NAME = 8,
}
#endregion

#region Configuration
## Nombre del paquete de la aplicación
var package_name: String = ""

## Código de versión actual (se obtiene automáticamente en Android)
var current_version_code: int = 0

## Si es true, muestra un diálogo automático cuando hay actualización
var show_dialog_on_update: bool = true

## Timeout para las peticiones HTTP (en segundos)
var request_timeout: float = DEFAULT_TIMEOUT

## Número máximo de reintentos en caso de error
var max_retries: int = DEFAULT_MAX_RETRIES

## Tiempo de espera entre reintentos (en segundos)
var retry_delay: float = DEFAULT_RETRY_DELAY

## Si es true, usa caché para reducir peticiones a la API
var use_cache: bool = true
#endregion

#region Private Variables
var _http_request: HTTPRequest
var _is_configured: bool = false
var _is_checking: bool = false
var _retry_count: int = 0
var _timer: Timer
var _cached_result: Dictionary = {}
var _cache_timestamp: float = 0.0
var _last_error: ErrorCode = ErrorCode.NONE
#endregion

#region Initialization
func _ready():
	_setup_http_request()
	_setup_timer()
	
	# Intentar configuración automática desde project settings
	if ProjectSettings.has_setting("application/config/apklis_package_name"):
		var pkg = ProjectSettings.get_setting("application/config/apklis_package_name")
		if pkg and pkg != "":
			package_name = pkg
	
	# Obtener versión automáticamente en Android
	if OS.has_feature("android"):
		current_version_code = _get_android_version_code()
		if current_version_code > 0:
			_is_configured = true
	
	# Log inicial
	_log_info("ApklisUpdateChecker inicializado")
	if _is_configured:
		_log_info("Auto-configurado: %s (v%d)" % [package_name, current_version_code])

func _setup_http_request():
	_http_request = HTTPRequest.new()
	_http_request.name = "HTTPRequest"
	_http_request.timeout = request_timeout
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)

func _setup_timer():
	_timer = Timer.new()
	_timer.name = "RetryTimer"
	_timer.one_shot = true
	add_child(_timer)
	_timer.timeout.connect(_on_retry_timer_timeout)
#endregion

#region Public Configuration Methods
## Configura el checker con los parámetros básicos
## Este es el método recomendado para configurar el sistema
func configure(pkg_name: String, version_code: int = 0) -> bool:
	if not _validate_package_name(pkg_name):
		_log_error("Nombre de paquete inválido: %s" % pkg_name)
		_last_error = ErrorCode.INVALID_PACKAGE_NAME
		return false
	
	package_name = pkg_name
	current_version_code = version_code
	_is_configured = true
	
	_log_info("Configurado: %s (v%d)" % [package_name, current_version_code])
	configuration_changed.emit()
	return true

## Configura desde los project settings de Godot
## Busca: application/config/apklis_package_name y application/config/version_code
func configure_from_project_settings() -> bool:
	var pkg = ProjectSettings.get_setting("application/config/apklis_package_name", "")
	var version = ProjectSettings.get_setting("application/config/version_code", 0)
	
	if pkg == "":
		_log_warning("No se encontró 'application/config/apklis_package_name' en project settings")
		return false
	
	return configure(pkg, version)

## Configura desde un archivo JSON
## Formato esperado: {"package_name": "com.example.app", "version_code": 1}
func configure_from_json(json_path: String) -> bool:
	if not FileAccess.file_exists(json_path):
		_log_error("Archivo no encontrado: %s" % json_path)
		return false
	
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		_log_error("No se pudo abrir el archivo: %s" % json_path)
		return false
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		_log_error("Error parseando JSON: %s" % json.get_error_message())
		return false
	
	var data = json.get_data()
	if not data is Dictionary:
		_log_error("JSON inválido: se esperaba un diccionario")
		return false
	
	var pkg = data.get("package_name", "")
	var version = data.get("version_code", 0)
	
	return configure(pkg, version)

## Configura los parámetros de reintento
func set_retry_config(max_retry: int, delay: float) -> void:
	max_retries = max(0, max_retry)
	retry_delay = max(0.1, delay)
	_log_info("Configuración de reintentos: max=%d, delay=%.1fs" % [max_retries, retry_delay])

## Establece el timeout de las peticiones HTTP
func set_timeout(timeout: float) -> void:
	request_timeout = max(1.0, timeout)
	if _http_request:
		_http_request.timeout = request_timeout
	_log_info("Timeout establecido: %.1fs" % request_timeout)

## Habilita o deshabilita el caché
func set_cache_enabled(enabled: bool) -> void:
	use_cache = enabled
	if not enabled:
		clear_cache()
	_log_info("Caché %s" % ("habilitado" if enabled else "deshabilitado"))

## Limpia el caché de resultados
func clear_cache() -> void:
	_cached_result.clear()
	_cache_timestamp = 0.0
	_log_info("Caché limpiado")
#endregion

#region Public Check Methods
## Verifica si hay actualizaciones disponibles
## Retorna true si la verificación se inició correctamente
func check_for_updates(force_check: bool = false) -> bool:
	# Validar configuración
	if not _is_configured or package_name == "":
		_log_error("No está configurado. Llama a configure() primero")
		_last_error = ErrorCode.NOT_CONFIGURED
		update_check_failed.emit("Not configured")
		return false
	
	# Verificar si ya hay una verificación en curso
	if _is_checking:
		_log_warning("Ya hay una verificación en curso")
		return false
	
	# Usar caché si está disponible y no es forzado
	if not force_check and use_cache and _is_cache_valid():
		_log_info("Usando resultado en caché")
		_emit_cached_result()
		return true
	
	# Iniciar verificación
	_is_checking = true
	_retry_count = 0
	update_check_started.emit()
	
	return _perform_check()

## Verifica actualizaciones de forma asíncrona y espera el resultado
## Retorna el resultado de la verificación o null si hay error
func check_for_updates_async() -> Dictionary:
	if not check_for_updates():
		return {}
	
	# Esperar a que termine la verificación
	var result = {}
	
	var update_callback = func(info: Dictionary):
		result = info
		result["has_update"] = true
	
	var no_update_callback = func(info: Dictionary):
		result = info
		result["has_update"] = false
	
	var error_callback = func(error: String):
		result = {"error": error, "has_update": false}
	
	update_available.connect(update_callback, CONNECT_ONE_SHOT)
	no_update_available.connect(no_update_callback, CONNECT_ONE_SHOT)
	update_check_failed.connect(error_callback, CONNECT_ONE_SHOT)
	
	# Esperar resultado con timeout
	var timeout_time = Time.get_ticks_msec() + (request_timeout + 1.0) * 1000
	while result.is_empty() and Time.get_ticks_msec() < timeout_time:
		await get_tree().process_frame
	
	return result

## Cancela la verificación actual
func cancel_check() -> void:
	if not _is_checking:
		return
	
	_http_request.cancel_request()
	_is_checking = false
	_timer.stop()
	_log_info("Verificación cancelada")
#endregion

#region Private Check Methods
func _perform_check() -> bool:
	var url = APKLIS_API_URL + "?package_name=" + package_name
	var headers = [
		"User-Agent: GodotApklisChecker/2.0",
		"Accept: application/json"
	]
	
	_log_info("Verificando actualizaciones: %s (intento %d/%d)" % [
		package_name, 
		_retry_count + 1, 
		max_retries + 1
	])
	
	var error = _http_request.request(url, headers)
	if error != OK:
		_handle_request_error(error)
		return false
	
	return true

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	_is_checking = false
	
	# Validar resultado de la petición
	if result != HTTPRequest.RESULT_SUCCESS:
		_handle_network_error(result)
		return
	
	# Validar código de respuesta HTTP
	if response_code != 200:
		_handle_http_error(response_code)
		return
	
	# Parsear JSON
	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	
	if parse_result != OK:
		_handle_json_error(json.get_error_message())
		return
	
	# Procesar respuesta
	var data = json.get_data()
	if not _validate_api_response(data):
		return
	
	# Extraer información de la app
	var app_info = data.results[0]
	var update_info = _build_update_info(app_info)
	
	# Guardar en caché
	if use_cache:
		_cached_result = update_info
		_cache_timestamp = Time.get_ticks_msec() / 1000.0
	
	# Emitir señales apropiadas
	var has_update = update_info.latest_version_code > current_version_code
	
	if has_update:
		_log_info("✓ Actualización disponible: v%s (código %d)" % [
			update_info.latest_version_name,
			update_info.latest_version_code
		])
		update_available.emit(update_info)
		
		if show_dialog_on_update:
			_show_update_dialog(update_info)
	else:
		_log_info("✓ No hay actualizaciones disponibles")
		no_update_available.emit(update_info)
	
	_last_error = ErrorCode.NONE
	_retry_count = 0
#endregion

#region Error Handling
func _handle_request_error(error: int) -> void:
	_last_error = ErrorCode.NETWORK_ERROR
	var error_msg = "Error iniciando petición HTTP: %d" % error
	_log_error(error_msg)
	_retry_or_fail(error_msg)

func _handle_network_error(result: int) -> void:
	_last_error = ErrorCode.NETWORK_ERROR
	var error_msg = "Error de red: %d" % result
	_log_error(error_msg)
	_retry_or_fail(error_msg)

func _handle_http_error(response_code: int) -> void:
	_last_error = ErrorCode.HTTP_ERROR
	var error_msg = "Error HTTP %d" % response_code
	_log_error(error_msg)
	
	# Algunos códigos HTTP no deberían reintentar
	if response_code in [400, 404, 403]:
		_fail_check(error_msg)
	else:
		_retry_or_fail(error_msg)

func _handle_json_error(error_message: String) -> void:
	_last_error = ErrorCode.JSON_PARSE_ERROR
	var error_msg = "Error parseando JSON: %s" % error_message
	_log_error(error_msg)
	_fail_check(error_msg)

func _retry_or_fail(error_msg: String) -> void:
	if _retry_count < max_retries:
		_retry_count += 1
		_log_info("Reintentando en %.1fs..." % retry_delay)
		_timer.start(retry_delay)
	else:
		_fail_check(error_msg)

func _on_retry_timer_timeout() -> void:
	_is_checking = true
	_perform_check()

func _fail_check(error_msg: String) -> void:
	_log_error("Verificación fallida: %s" % error_msg)
	update_check_failed.emit(error_msg)
	_retry_count = 0
#endregion

#region Validation
func _validate_package_name(pkg_name: String) -> bool:
	if pkg_name == "":
		return false
	
	# Validar formato básico de package name (ej: com.example.app)
	var regex = RegEx.new()
	regex.compile("^[a-z][a-z0-9_]*(\\.[a-z0-9_]+)+$")
	return regex.search(pkg_name) != null

func _validate_api_response(data) -> bool:
	if not data is Dictionary:
		_log_error("Respuesta API inválida: no es un diccionario")
		_last_error = ErrorCode.JSON_PARSE_ERROR
		_fail_check("Invalid API response format")
		return false
	
	if not data.has("results") or data.results.size() == 0:
		_log_error("No se encontró la aplicación en Apklis")
		_last_error = ErrorCode.NO_APP_FOUND
		_fail_check("App not found")
		return false
	
	var app_info = data.results[0]
	if not app_info.has("last_release"):
		_log_error("No hay información de release")
		_last_error = ErrorCode.NO_RELEASE_INFO
		_fail_check("No release info available")
		return false
	
	return true
#endregion

#region Cache
func _is_cache_valid() -> bool:
	if _cached_result.is_empty():
		return false
	
	var current_time = Time.get_ticks_msec() / 1000.0
	var cache_age = current_time - _cache_timestamp
	
	return cache_age < CACHE_DURATION

func _emit_cached_result() -> void:
	var has_update = _cached_result.latest_version_code > current_version_code
	
	if has_update:
		update_available.emit(_cached_result)
		if show_dialog_on_update:
			_show_update_dialog(_cached_result)
	else:
		no_update_available.emit(_cached_result)
#endregion

#region Data Building
func _build_update_info(app_info: Dictionary) -> Dictionary:
	var last_release = app_info.last_release
	
	return {
		"app_name": app_info.get("name", ""),
		"package_name": app_info.get("package_name", package_name),
		"description": app_info.get("description", ""),
		"current_version_code": current_version_code,
		"latest_version_code": last_release.get("version_code", 0),
		"latest_version_name": last_release.get("version_name", ""),
		"changelog": last_release.get("changelog", "Sin información de cambios"),
		"download_url": last_release.get("apk_file", ""),
		"size": last_release.get("human_readable_size", "Desconocido"),
		"icon": last_release.get("icon", ""),
		"rating": app_info.get("rating", 0.0),
		"download_count": app_info.get("download_count", 0),
		"check_timestamp": Time.get_unix_time_from_system(),
	}
#endregion

#region UI
func _show_update_dialog(info: Dictionary) -> void:
	var dialog = AcceptDialog.new()
	get_tree().root.add_child(dialog)
	
	dialog.title = "Actualización disponible"
	dialog.dialog_text = """
Nueva versión disponible: %s

Versión actual: v%d
Nueva versión: v%d

Cambios:
%s

Tamaño: %s
""" % [
		info.latest_version_name,
		info.current_version_code,
		info.latest_version_code,
		info.changelog,
		info.size
	]
	
	dialog.ok_button_text = "Ir a Apklis"
	dialog.confirmed.connect(func(): _open_apklis_page(info.package_name))
	dialog.canceled.connect(func(): dialog.queue_free())
	dialog.close_requested.connect(func(): dialog.queue_free())
	
	dialog.add_cancel_button("Más tarde")
	dialog.popup_centered()

func _open_apklis_page(pkg_name: String) -> void:
	var url = "https://www.apklis.cu/application/" + pkg_name
	OS.shell_open(url)
#endregion

#region Android Integration
func _get_android_version_code() -> int:
	if not OS.has_feature("android"):
		return 0
	
	if not Engine.has_singleton("JavaClassWrapper"):
		_log_warning("JavaClassWrapper no disponible")
		return 0
	
	var activity = Engine.get_singleton("JavaClassWrapper").wrap("android.app.Activity")
	if not activity:
		_log_warning("No se pudo obtener Activity")
		return 0
	
	var package_manager = activity.getPackageManager()
	var package_info = package_manager.getPackageInfo(OS.get_name(), 0)
	
	if package_info:
		return package_info.versionCode
	
	return 0
#endregion

#region Utilities
func get_status() -> Dictionary:
	return {
		"is_configured": _is_configured,
		"is_checking": _is_checking,
		"package_name": package_name,
		"version_code": current_version_code,
		"last_error": _last_error,
		"cache_valid": _is_cache_valid(),
		"retry_count": _retry_count,
	}

func get_last_error_code() -> ErrorCode:
	return _last_error

func get_last_error_string() -> String:
	match _last_error:
		ErrorCode.NONE: return "No error"
		ErrorCode.NOT_CONFIGURED: return "Not configured"
		ErrorCode.NETWORK_ERROR: return "Network error"
		ErrorCode.HTTP_ERROR: return "HTTP error"
		ErrorCode.JSON_PARSE_ERROR: return "JSON parse error"
		ErrorCode.NO_APP_FOUND: return "App not found"
		ErrorCode.NO_RELEASE_INFO: return "No release info"
		ErrorCode.TIMEOUT: return "Timeout"
		ErrorCode.INVALID_PACKAGE_NAME: return "Invalid package name"
		_: return "Unknown error"

func _log_info(message: String) -> void:
	print("[ApklisUpdate] INFO: %s" % message)

func _log_warning(message: String) -> void:
	push_warning("[ApklisUpdate] WARNING: %s" % message)

func _log_error(message: String) -> void:
	push_error("[ApklisUpdate] ERROR: %s" % message)
#endregion
