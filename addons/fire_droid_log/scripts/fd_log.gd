extends Node


enum LogLevel {
	TRACE,
	DEBUG,
	INFO,
	NOTICE,
	WARNING,
	ERROR,
	CRITICAL,
}


const Colors: Dictionary = {
	LogLevel.TRACE: "gray",
	LogLevel.DEBUG: "gray",
	LogLevel.INFO: "gray",
	LogLevel.NOTICE: "cyan",
	LogLevel.WARNING: "yellow",
	LogLevel.ERROR: "red",
	LogLevel.CRITICAL: "red",
}


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func get_enable_log_level_setting_path(level: LogLevel) -> String:
	const LOG_LEVEL_SETTING_PATH: String = "FDLog/log_level/"
	return (
		LOG_LEVEL_SETTING_PATH + "enable_" + LogLevel.keys()[level].to_lower()
	)


func log_message(message: String, level: LogLevel = LogLevel.INFO) -> void:
	if not is_level_enabled(level):
		return
	var timestamp: String = Time.get_time_string_from_system()
	var color: String = Colors.get(level, "gray")
	if level == LogLevel.WARNING:
		push_warning("[%s]: %s" % [timestamp, message])
	if level == LogLevel.ERROR:
		push_error("[%s]: %s" % [timestamp, message])
	print_rich("[color=%s][%s]: %s[/color]" % [color, timestamp, message])


func can_print_log_level() -> bool:
	return (
		ProjectSettings.get_setting(get_print_log_level_setting_path(), true)
	)


func is_level_enabled(level: LogLevel) -> bool:
	return ProjectSettings.get_setting(
		get_enable_log_level_setting_path(level), true
	)


