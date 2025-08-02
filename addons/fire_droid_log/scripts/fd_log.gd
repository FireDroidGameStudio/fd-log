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
const SettingPath = preload("res://addons/fire_droid_log/scripts/setting_path.gd")


const DEFAULT_LOG_FILE_NAME_PREFIX: String = "log_file"
const LOG_FILE_EXTENSION: String = "log"

const DEFAULT_COLOR: Color = Color.GRAY
const DEFAULT_BG_COLOR: Color = Color.TRANSPARENT
const DEFAULT_FG_COLOR: Color = Color.TRANSPARENT
const DEFAULT_BOLD: bool = false
const DEFAULT_ITALIC: bool = false
const DEFAULT_UNDERLINED: bool = false
const DEFAULT_STRIKETHROUGH: bool = false

const DEFAULT_SETTINGS: Dictionary[StringName, Variant] = {
	&"color": DEFAULT_COLOR,
	&"bg_color": DEFAULT_BG_COLOR,
	&"fg_color": DEFAULT_FG_COLOR,
	&"bold": DEFAULT_BOLD,
	&"italic": DEFAULT_ITALIC,
	&"underlined": DEFAULT_UNDERLINED,
	&"strikethrough": DEFAULT_STRIKETHROUGH,
}


var DefaultStyle: Dictionary[LogLevel, Dictionary] = {
	LogLevel.TRACE: { &"color": Color.GRAY, &"italic": true },
	LogLevel.DEBUG: { &"color": Color.WHITE },
	LogLevel.INFO: { &"color": Color.DEEP_SKY_BLUE },
	LogLevel.NOTICE: { &"color": Color.CYAN, &"bold": true },
	LogLevel.WARNING: { &"color": Color.YELLOW },
	LogLevel.ERROR: { &"color": Color.RED },
	LogLevel.CRITICAL: {
		&"color": Color.WHITE,
		&"bg_color": Color.RED,
		&"bold": true,
	},
}

var _current_file_path: String = ""


func _init() -> void:
	DefaultStyle.make_read_only()


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func log_message(message: String, level: LogLevel = LogLevel.INFO) -> void:
	if not is_level_enabled(level):
		return
	var datetime_dict: Dictionary = Time.get_datetime_dict_from_system()
	var timestamp: String = Time.get_datetime_string_from_datetime_dict(
		datetime_dict, false
	)
	#var timestamp: String = Time.get_time_string_from_system()
	var style: LogStyle = get_log_style(level)
	if can_print_log_level():
		var level_string: String = LogLevel.keys().get(level)
		message = "[%s]: %s" % [level_string, message]
	if level == LogLevel.WARNING:
		push_warning("[%s]: %s" % [timestamp, message])
	elif level == LogLevel.ERROR or level == LogLevel.CRITICAL:
		push_error("[%s]: %s" % [timestamp, message])
	print_rich(style.get_stylized_text("[%s]: %s" % [timestamp, message]))
	if _current_file_path.is_empty():
		var file_name: String = _get_log_file_filename(datetime_dict)
		_current_file_path = ProjectSettings.get_setting(
			SettingPath.LOG_FILE_ROOT_DIR,
			ProjectSettings.globalize_path("res://").trim_suffix("/")
		) + "/" + file_name


func can_print_log_level() -> bool:
	return ProjectSettings.get_setting(SettingPath.PRINT_LOG_LEVEL, true)


func is_level_enabled(level: LogLevel) -> bool:
	return ProjectSettings.get_setting(SettingPath.ENABLE_LEVEL[level], true)


func get_default_style_setting(level: LogLevel, setting: StringName) -> Variant:
	return DefaultStyle[level].get(setting, DEFAULT_SETTINGS.get(setting))


func get_style_setting(level: LogLevel, setting: StringName) -> Variant:
	return ProjectSettings.get_setting(
		SettingPath.LOG_STYLE[level][setting],
		get_default_style_setting(level, setting)
	)


func get_log_style(level: LogLevel) -> LogStyle:
	return LogStyle.new(
		get_style_setting(level, &"color"),
		get_style_setting(level, &"bg_color"),
		get_style_setting(level, &"fg_color"),
		get_style_setting(level, &"bold"),
		get_style_setting(level, &"italic"),
		get_style_setting(level, &"underlined"),
		get_style_setting(level, &"strikethrough"),
	)


func _get_log_file_filename(datetime_dict: Dictionary) -> String:
	var prefix: String = ProjectSettings.get_setting(
		SettingPath.LOG_FILE_NAME_PREFIX, DEFAULT_LOG_FILE_NAME_PREFIX
	)
	if not prefix.is_valid_filename():
		prefix = DEFAULT_LOG_FILE_NAME_PREFIX
	var filename: String = "%s_%02d%02d%02d_%02d%02d%02d.%s" % [
		prefix,
		datetime_dict.get(&"year", ""),
		datetime_dict.get(&"month", ""),
		datetime_dict.get(&"day", ""),
		datetime_dict.get(&"hour", ""),
		datetime_dict.get(&"minute", ""),
		datetime_dict.get(&"second", ""),
		LOG_FILE_EXTENSION
	]
	return filename


class LogStyle extends Resource:
	var color: Color = DEFAULT_COLOR
	var bg_color: Color = DEFAULT_BG_COLOR
	var fg_color: Color = DEFAULT_FG_COLOR
	var bold: bool = DEFAULT_BOLD
	var italic: bool = DEFAULT_ITALIC
	var underlined: bool = DEFAULT_UNDERLINED
	var strikethrough: bool = DEFAULT_STRIKETHROUGH


	func _init(
		color: Color = DEFAULT_COLOR,
		bg_color: Color = DEFAULT_BG_COLOR,
		fg_color: Color = DEFAULT_FG_COLOR,
		bold: bool = DEFAULT_BOLD,
		italic: bool = DEFAULT_ITALIC,
		underlined: bool = DEFAULT_UNDERLINED,
		strikethrough: bool = DEFAULT_STRIKETHROUGH
	) -> void:
		self.color = color
		self.bg_color = bg_color
		self.fg_color = fg_color
		self.bold = bold
		self.italic = italic
		self.underlined = underlined
		self.strikethrough = strikethrough


	static func create(args: Dictionary) -> LogStyle:
		return LogStyle.new(
			args.get(&"color", DEFAULT_COLOR),
			args.get(&"bg_color", DEFAULT_BG_COLOR),
			args.get(&"fg_color", DEFAULT_FG_COLOR),
			args.get(&"bold", DEFAULT_BOLD),
			args.get(&"italic", DEFAULT_ITALIC),
			args.get(&"underlined", DEFAULT_UNDERLINED),
			args.get(&"strikethrough", DEFAULT_STRIKETHROUGH)
		)


	func is_equal_to(style: LogStyle) -> bool:
		const PROPERTIES: Array[StringName] = [
			&"color",
			&"bg_color",
			&"fg_color",
			&"bold",
			&"italic",
			&"underlined",
			&"strikethrough"
		]
		for property: StringName in PROPERTIES:
			if not (get(property) == style.get(property)):
				return false
		return true


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
