extends Node

var _menu_opened: bool = false

# Configs.
var _mouse_camera_sensivity: float = 0.003
var _camera_fov: float = 75.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		_toggle_menu()


func get_camera_sensivity() -> float:
	return _mouse_camera_sensivity


func get_camera_fov() -> float:
	return _camera_fov


func menu_opened() -> bool:
	return _menu_opened


func _toggle_menu() -> void:
	_menu_opened = !_menu_opened
	
	if _menu_opened:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
