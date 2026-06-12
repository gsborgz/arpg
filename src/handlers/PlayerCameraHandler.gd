class_name PlayerCameraHandler


enum CameraMode { FIRST_PERSON, THIRD_PERSON }

const CAMERA_DOWN_LIMIT_FP: float = deg_to_rad(-90)
const CAMERA_UP_LIMIT_FP: float = deg_to_rad(90)
const CAMERA_DOWN_LIMIT_TP: float = deg_to_rad(-80)
const CAMERA_UP_LIMIT_TP: float = deg_to_rad(80)
const FOV_CHANGE_SPRINT: float = 1.5
const BOB_FREQ: float = 2.0
const BOB_AMP: float = 0.02
const ZOOM_STEP: float = 0.5
const ZOOM_MIN: float = 0.0
const ZOOM_MIN_TP: float = 1.5
const ZOOM_MAX: float = 4.0
const ZOOM_LERP_SPEED: float = 5.0
const TP_CAMERA_X_OFFSET: float = 0.5
const OFFSET_LERP_SPEED: float = 5.0

var t_bob: float = 0.0
var _target_spring_length: float = 0.0


func handle_camera_input(event: InputEvent) -> void:
	if GameManager.menu_opened:
		return
	
	if event is InputEventMouseMotion:
		_handle_camera_rotation(event)
	elif event is InputEventMouseButton and event.pressed:
		_handle_scroll_zoom(event)


func handle_camera_physics(delta: float) -> void:
	_handle_zoom(delta)
	_handle_camera_tp_offset(delta)
	_handle_mesh_visibility()
	_handle_fov_change(delta)
	_handle_bobbing(delta)


func _is_first_person() -> bool:
	return _target_spring_length == ZOOM_MIN


func _handle_zoom(delta: float) -> void:
	if Input.is_action_just_pressed("cam_mode"):
		_target_spring_length = ZOOM_MIN_TP if _is_first_person() else ZOOM_MIN
	
	var new_length: float = lerpf(
		PlayerManager.spring_arm.spring_length,
		_target_spring_length,
		delta * ZOOM_LERP_SPEED
	)
	
	if absf(new_length - _target_spring_length) < 0.01:
		new_length = _target_spring_length
	
	PlayerManager.spring_arm.spring_length = new_length


func _handle_camera_tp_offset(delta: float) -> void:
	var target_x: float = 0.0 if _is_first_person() else TP_CAMERA_X_OFFSET
	
	PlayerManager.spring_arm.position.x = lerpf(
		PlayerManager.spring_arm.position.x,
		target_x,
		delta * OFFSET_LERP_SPEED
	)


func _handle_mesh_visibility() -> void:
	PlayerManager.mesh.visible = !_is_first_person()


func _handle_fov_change(delta: float) -> void:
	if PlayerManager.movement_handler.is_moving():
		var velocity_clamped: float = clamp(PlayerManager.character.velocity.length(), 0.5, PlayerManager.movement_handler.current_speed() * 2)
		var target_fov: float = GameManager.camera_config.fov + _current_fov_change() * velocity_clamped
		
		PlayerManager.camera.fov = lerp(PlayerManager.camera.fov, target_fov, delta * 8.0)
	elif PlayerManager.character.is_on_floor():
		PlayerManager.camera.fov = lerp(PlayerManager.camera.fov, GameManager.camera_config.fov, delta * 8.0)


func _handle_bobbing(delta: float) -> void:
	if PlayerManager.character.is_on_floor() and PlayerManager.character.velocity.length() > 0.1:
		t_bob += delta * PlayerManager.character.velocity.length()

		PlayerManager.spring_arm.position.y = sin(t_bob * BOB_FREQ) * BOB_AMP
		PlayerManager.camera.transform.origin.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	else:
		t_bob = 0.0
		PlayerManager.spring_arm.position.y = lerpf(PlayerManager.spring_arm.position.y, 0.0, delta * 10.0)
		PlayerManager.camera.transform.origin.x = lerpf(PlayerManager.camera.transform.origin.x, 0.0, delta * 10.0)


func _handle_camera_rotation(event: InputEvent) -> void:
	var sensitivity := GameManager.camera_config.sensitivity
	
	PlayerManager.head.rotate_y(-event.relative.x * sensitivity)
	PlayerManager.spring_arm.rotate_x(-event.relative.y * sensitivity)
	
	var down_limit := CAMERA_DOWN_LIMIT_FP if _is_first_person() else CAMERA_DOWN_LIMIT_TP
	var up_limit := CAMERA_UP_LIMIT_FP if _is_first_person() else CAMERA_UP_LIMIT_TP
	
	PlayerManager.spring_arm.rotation.x = clamp(PlayerManager.spring_arm.rotation.x, down_limit, up_limit)


func _handle_scroll_zoom(event: InputEvent) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if _is_first_person():
			_target_spring_length = ZOOM_MIN_TP
		else:
			_target_spring_length = clamp(_target_spring_length + ZOOM_STEP, ZOOM_MIN_TP, ZOOM_MAX)
	elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		if _target_spring_length <= ZOOM_MIN_TP:
			_target_spring_length = ZOOM_MIN
		else:
			_target_spring_length = clamp(_target_spring_length - ZOOM_STEP, ZOOM_MIN_TP, ZOOM_MAX)


func _current_fov_change() -> float:
	return FOV_CHANGE_SPRINT if PlayerManager.movement_handler.is_sprinting() else 0.0
