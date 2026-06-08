class_name PlayerCameraHandler


const CAMERA_DOWN_LIMIT: float = -90
const CAMERA_UP_LIMIT: float = 90
const FOV_CHANGE_SPRINT: float = 1.5
const FOV_CHANGE_WALK: float = 0.5

var character: CharacterBody3D
var head: Node3D
var camera: Camera3D


func _init(_character: CharacterBody3D, _head: Node3D, _camera: Camera3D) -> void:
	character = _character
	head = _head
	camera = _camera


func handle_camera_rotation(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !GameManager.menu_opened():
		var sensivity = GameManager.get_camera_sensivity()
		
		head.rotate_y(-event.relative.x * sensivity)
		camera.rotate_x(-event.relative.y * sensivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(CAMERA_DOWN_LIMIT), deg_to_rad(CAMERA_UP_LIMIT))


func handle_fov_change(delta: float, movement_handler: PlayerMovementHandler) -> void:
	if movement_handler.is_sprinting or movement_handler.is_moving:
		var fov_change = FOV_CHANGE_SPRINT if movement_handler.is_sprinting else FOV_CHANGE_WALK
		var velocity_clamped = clamp(character.velocity.length(), 0.5, movement_handler.speed * 2)
		var target_fov = GameManager.get_camera_fov() + fov_change * velocity_clamped
		
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	elif character.is_on_floor():
		camera.fov = lerp(camera.fov, GameManager.get_camera_fov(), delta * 8.0)
