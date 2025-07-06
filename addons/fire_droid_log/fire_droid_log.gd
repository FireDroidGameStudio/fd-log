@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("FDLog", "res://addons/fire_droid_log/scripts/fd_log.gd")
	pass


func _exit_tree() -> void:
	remove_autoload_singleton("FDLog")
	pass
