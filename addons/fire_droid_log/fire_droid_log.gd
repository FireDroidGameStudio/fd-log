@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("FDLog", "res://addons/fire_droid_log/scripts/fd_log.gd")
	for level: FDLog.LogLevel in FDLog.LogLevel.values():
		_setup_custom_setting(
			FDLog.get_enable_log_level_setting_path(level), true, TYPE_BOOL
		)
	pass


func _exit_tree() -> void:
	remove_autoload_singleton("FDLog")
	ProjectSettings.save_custom("override.cfg")
	pass


func _setup_custom_setting(
	path: String,
	initial_value: Variant,
	type: int,
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
