@tool
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


var DefaultColors: Dictionary[LogLevel, LogStyle] = {
	LogLevel.TRACE: LogStyle.new().apply_color(Color.GRAY),
	LogLevel.DEBUG: LogStyle.new().apply_color(Color.WHITE),
	LogLevel.INFO: LogStyle.new().apply_color(Color.DEEP_SKY_BLUE),
	LogLevel.NOTICE: LogStyle.new().apply_color(Color.CYAN).apply_bold(true),
	LogLevel.WARNING: LogStyle.new().apply_color(Color.YELLOW),
	LogLevel.ERROR: LogStyle.new().apply_color(Color.RED),
	LogLevel.CRITICAL: (
		LogStyle.new().apply_color(Color.WHITE).apply_bg_color(Color.RED).apply_bold(true)
	),
}


func _init() -> void:
	DefaultColors.make_read_only()


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


func get_log_level_style_setting_path(level: LogLevel) -> String:
	const LOG_LEVEL_STYLE_SETTING_PATH: String = "FDLog/log_style/"
	return (
		LOG_LEVEL_STYLE_SETTING_PATH + LogLevel.keys()[level].to_lower() + "_style"
	)


func get_print_log_level_setting_path() -> String:
	const PRINT_LOG_LEVEL_SETTING_PATH: String = "FDLog/log_style/print_log_level"
	return PRINT_LOG_LEVEL_SETTING_PATH


func log_message(message: String, level: LogLevel = LogLevel.INFO) -> void:
	if not is_level_enabled(level):
		return
	var timestamp: String = Time.get_time_string_from_system()
	var style: LogStyle = get_log_level_style(level)
	if can_print_log_level():
		var level_string: String = LogLevel.keys().get(level)
		message = "[%s]: %s" % [level_string, message]
	if level == LogLevel.WARNING:
		push_warning("[%s]: %s" % [timestamp, message])
	elif level == LogLevel.ERROR or level == LogLevel.CRITICAL:
		push_error("[%s]: %s" % [timestamp, message])
	print_rich(style.get_stylized_text("[%s]: %s" % [timestamp, message]))


func can_print_log_level() -> bool:
	return (
		ProjectSettings.get_setting(get_print_log_level_setting_path(), true)
	)


func is_level_enabled(level: LogLevel) -> bool:
	return ProjectSettings.get_setting(
		get_enable_log_level_setting_path(level), true
	)


func get_log_level_style(level: LogLevel) -> LogStyle:
	return ProjectSettings.get_setting(
		get_log_level_style_setting_path(level),
		DefaultColors.get(level, LogStyle.new().apply_color(Color.GRAY))
	)


class LogStyle:
	var color: Color = Color.GRAY
	var bg_color: Color = Color.TRANSPARENT
	var fg_color: Color = Color.TRANSPARENT
	var bold: bool = false
	var italic: bool = false
	var underlined: bool = false
	var strikethrough: bool = false


	func apply_color(color: Color) -> LogStyle:
		self.color = color
		return self


	func apply_bg_color(bg_color: Color) -> LogStyle:
		self.bg_color = bg_color
		return self


	func apply_fg_color(fg_color: Color) -> LogStyle:
		self.fg_color = fg_color
		return self


	func apply_bold(bold: bool) -> LogStyle:
		self.bold = bold
		return self


	func apply_italic(italic: bool) -> LogStyle:
		self.italic = italic
		return self


	func apply_underlined(underlined: bool) -> LogStyle:
		self.underlined = underlined
		return self


	func apply_strikethrough(strikethrough: bool) -> LogStyle:
		self.strikethrough = strikethrough
		return self


	func get_stylized_text(text: String) -> String:
		var style_string_begin: String = "[color=#%s]" % [color.to_html()]
		var style_string_end: String = "[/color]"
		if not is_zero_approx(bg_color.a):
			style_string_begin += "[bgcolor=#%s]" % [bg_color.to_html()]
			style_string_end = "[/bgcolor]" + style_string_end
		if not is_zero_approx(fg_color.a):
			style_string_begin += "[fgcolor=#%s]" % [fg_color.to_html()]
			style_string_end = "[/fgcolor]" + style_string_end
		style_string_begin += (
			"[b]" if bold else ""
			+ "[i]" if italic else ""
			+ "[u]" if underlined else ""
			+ "[s]" if strikethrough else ""
		)
		style_string_end = (
			"[/s]" if strikethrough else ""
			+ "[/u]" if underlined else ""
			+ "[/i]" if italic else ""
			+ "[/b]" if bold else ""
		) + style_string_end
		return style_string_begin + text + style_string_end
