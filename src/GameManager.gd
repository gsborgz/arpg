extends Node

signal player_ready(stats: PlayerStats)

var menu_opened: bool = false
var player_stats: PlayerStats:
	set(value):
		player_stats = value
		player_ready.emit(value)

# Configs.
var camera_config = CameraConfig.new()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_toggle_menu()


func _toggle_menu() -> void:
	menu_opened = !menu_opened
	
	if menu_opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
