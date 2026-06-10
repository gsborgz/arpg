class_name PlayerCameraHandler


const CAMERA_DOWN_LIMIT: float = -90
const CAMERA_UP_LIMIT: float = 90
const FOV_CHANGE_SPRINT: float = 1.5
const FOV_CHANGE_RUNNING: float = 0.0
const FOV_CHANGE_WALK: float = 0.0
const BOB_FREQ: float = 2.0
const BOB_AMP: float = 0.02

var t_bob: float = 0.0


func handle_camera_rotation(event: InputEvent) -> void:
	if event is InputEventMouseMotion && !GameManager.menu_opened:
		var sensivity = GameManager.camera_config.sensivity
		
		PlayerManager.head.rotate_y(-event.relative.x * sensivity)
		PlayerManager.camera.rotate_x(-event.relative.y * sensivity)
		PlayerManager.camera.rotation.x = clamp(PlayerManager.camera.rotation.x, deg_to_rad(CAMERA_DOWN_LIMIT), deg_to_rad(CAMERA_UP_LIMIT))


func handle_camera_physics(delta: float) -> void:
	_handle_fov_change(delta)
	_handle_bobbing(delta)


func _handle_fov_change(delta: float) -> void:
	if PlayerManager.MovementHandler.is_moving():
		var velocity_clamped = clamp(PlayerManager.character.velocity.length(), 0.5, PlayerManager.MovementHandler.current_speed() * 2)
		var target_fov = GameManager.camera_config.fov + _current_fov_change() * velocity_clamped
		
		PlayerManager.camera.fov = lerp(PlayerManager.camera.fov, target_fov, delta * 8.0)
	elif PlayerManager.character.is_on_floor():
		PlayerManager.camera.fov = lerp(PlayerManager.camera.fov, GameManager.camera_config.fov, delta * 8.0)


func _handle_bobbing(delta: float) -> void:
	if PlayerManager.character.is_on_floor() and PlayerManager.character.velocity.length() > 0.1:
		t_bob += delta * PlayerManager.character.velocity.length() * float(PlayerManager.character.is_on_floor())
		
		var pos = Vector3.ZERO
		
		pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
		
		PlayerManager.camera.transform.origin = pos
	else:
		t_bob = 0.0
		PlayerManager.camera.transform.origin = PlayerManager.camera.transform.origin.lerp(Vector3.ZERO, delta * 10.0)


func _current_fov_change() -> float:
	if PlayerManager.MovementHandler.is_sprinting():
		return FOV_CHANGE_SPRINT 
	elif PlayerManager.MovementHandler.is_walking():
		return FOV_CHANGE_WALK
	else:
		return FOV_CHANGE_RUNNING
