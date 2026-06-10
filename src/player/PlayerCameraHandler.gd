class_name PlayerCameraHandler


const CAMERA_DOWN_LIMIT: float = -90
const CAMERA_UP_LIMIT: float = 90
const FOV_CHANGE_SPRINT: float = 1.5
const FOV_CHANGE_RUNNING: float = 0.0
const FOV_CHANGE_WALK: float = 0.0
const BOB_FREQ: float = 2.0
const BOB_AMP: float = 0.02

var character: CharacterBody3D
var head: Node3D
var camera: Camera3D
var movement_handler: PlayerMovementHandler

var t_bob: float = 0.0


func _init(_character: CharacterBody3D, _head: Node3D, _camera: Camera3D, _movement_handler: PlayerMovementHandler) -> void:
	character = _character
	head = _head
	camera = _camera
	movement_handler = _movement_handler


func handle_camera_rotation(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !GameManager.menu_opened:
		var sensivity = GameManager.camera_config.sensivity
		
		head.rotate_y(-event.relative.x * sensivity)
		camera.rotate_x(-event.relative.y * sensivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(CAMERA_DOWN_LIMIT), deg_to_rad(CAMERA_UP_LIMIT))


func handle_camera_physics(delta: float) -> void:
	_handle_fov_change(delta)
	_handle_bobbing(delta)


func _handle_fov_change(delta: float) -> void:
	if movement_handler.is_moving():
		var velocity_clamped = clamp(character.velocity.length(), 0.5, movement_handler.current_speed() * 2)
		var target_fov = GameManager.camera_config.fov + _current_fov_change(movement_handler) * velocity_clamped
		
		camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	elif character.is_on_floor():
		camera.fov = lerp(camera.fov, GameManager.camera_config.fov, delta * 8.0)


func _handle_bobbing(delta: float) -> void:
	if character.is_on_floor() and character.velocity.length() > 0.1:
		t_bob += delta * character.velocity.length() * float(character.is_on_floor())
		
		var pos = Vector3.ZERO
		
		pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
		
		camera.transform.origin = pos
	else:
		t_bob = 0.0
		camera.transform.origin = camera.transform.origin.lerp(Vector3.ZERO, delta * 10.0)


func _current_fov_change(movement_handler: PlayerMovementHandler) -> float:
	if movement_handler.is_sprinting():
		return FOV_CHANGE_SPRINT 
	elif movement_handler.is_walking():
		return FOV_CHANGE_WALK
	else:
		return FOV_CHANGE_RUNNING
