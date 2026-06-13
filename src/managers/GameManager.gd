extends Node


var menu_opened: bool = false

# Configs.
var camera_config: CameraConfig = CameraConfig.new()


func _process(_delta: float) -> void:
	if menu_opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_toggle_menu()


func _toggle_menu() -> void:
	menu_opened = !menu_opened
