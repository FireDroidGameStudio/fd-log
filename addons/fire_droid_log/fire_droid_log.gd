@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("FDLog", "res://addons/fire_droid_log/scripts/fd_log.gd")
	_setup_custom_setting(FDLog.get_print_log_level_setting_path(), TYPE_BOOL, true)
	for level: FDLog.LogLevel in FDLog.LogLevel.values():
		_setup_custom_setting(
			FDLog.get_enable_log_level_setting_path(level), TYPE_BOOL, true
		)
		var style_root_path: String = FDLog.get_log_level_style_setting_path(level)
		_setup_style_color_properties(level, style_root_path)
		_setup_style_flags_properties(level, style_root_path)
	pass


func _exit_tree() -> void:
	remove_autoload_singleton("FDLog")
	ProjectSettings.save_custom("override.cfg")
	pass


func _setup_custom_setting(
	path: String,
	type: int,
	initial_value: Variant,
	args: Dictionary = {},
	is_basic: bool = true
) -> void:
	if not ProjectSettings.get_setting(path):
		ProjectSettings.set_setting(path, initial_value)
	ProjectSettings.set_initial_value(path, initial_value)
	ProjectSettings.add_property_info({
		&"name": path,
		&"usage": args.get(&"usage", PROPERTY_USAGE_DEFAULT),
		&"type": type,
		&"hint": args.get(&"hint", PROPERTY_HINT_NONE),
		&"hint_string": args.get(&"hint_string", "")
	})
	ProjectSettings.set_as_basic(path, true)


func _setup_style_color_properties(level: FDLog.LogLevel, style_root_path: String) -> void:
	_setup_custom_setting(
		style_root_path + "/color", TYPE_COLOR,
		FDLog.DefaultColors[level].get(&"color", FDLog.DEFAULT_COLOR)
	)
	_setup_custom_setting(
		style_root_path + "/bg_color", TYPE_COLOR,
		FDLog.DefaultColors[level].get(&"bg_color", FDLog.DEFAULT_BG_COLOR)
	)
	_setup_custom_setting(
		style_root_path + "/fg_color", TYPE_COLOR,
		FDLog.DefaultColors[level].get(&"fg_color", FDLog.DEFAULT_FG_COLOR)
	)


func _setup_style_flags_properties(level: FDLog.LogLevel, style_root_path: String) -> void:
	_setup_custom_setting(
		style_root_path + "/bold", TYPE_BOOL,
		FDLog.DefaultColors[level].get(&"bold", FDLog.DEFAULT_BOLD)
	)
	_setup_custom_setting(
		style_root_path + "/italic", TYPE_BOOL,
		FDLog.DefaultColors[level].get(&"italic", FDLog.DEFAULT_ITALIC)
	)
	_setup_custom_setting(
		style_root_path + "/underlined", TYPE_BOOL,
		FDLog.DefaultColors[level].get(&"underlined", FDLog.DEFAULT_UNDERLINED)
	)
	_setup_custom_setting(
		style_root_path + "/strikethrough", TYPE_BOOL,
		FDLog.DefaultColors[level].get(&"strikethrough", FDLog.DEFAULT_STRIKETHROUGH)
	)
