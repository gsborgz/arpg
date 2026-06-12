class_name PlayerMovementHandler


signal state_changed(new_state: MoveState)

enum MoveState {
	IDLE,
	WALKING,
	RUNNING,
	SPRINTING,
	JUMPING,
	FALLING
}

const BASE_SPEED: float = 5.0
const WALKING_SPEED_MODIFIER: float = 0.2
const SPRINTING_SPEED_MODIFIER: float = 1.6
const CROUCH_SPEED_MODIFIER: float = 0.3
const CROUCH_WALK_SPEED_MODIFIER: float = 0.15
const JUMP_FORCE: float = 6.5
const FALL_SPEED: float = 2.0
const CROUCH_JUMP_MODIFIER: float = 0.8
const STAND_HEIGHT: float = 2.0
const CROUCH_HEIGHT: float = 0.5
const CROUCH_LERP_SPEED: float = 10.0
const JUMP_STAMINA_COST: float = 5.0

var movement_enabled: bool = true
var sprint_enabled: bool = true
var speed_multiplier: float = 1.0

var _move_dir: Vector2 = Vector2.ZERO
var _jump_pressed: bool = false
var _crouch_pressed: bool = false
var _sprint_held: bool = false
var _walk_held: bool = false

var current_state: MoveState = MoveState.IDLE:
	set(value):
		if value == current_state:
			return
		current_state = value
		state_changed.emit(current_state)

var is_crouching: bool = false


func handle_movement(delta: float) -> void:
	_read_input()
	_add_gravity(delta)
	_update_state()
	_update_crouch(delta)

	var draining_stamina := false

	if movement_enabled and not GameManager.menu_opened:
		_handle_actions()
		_apply_movement(delta)
		
		draining_stamina = is_moving() and is_sprinting()
	else:
		PlayerManager.character.velocity.x = 0.0
		PlayerManager.character.velocity.z = 0.0

	PlayerManager.stats_handler.process_stamina(delta, draining_stamina)
	PlayerManager.character.move_and_slide()


func current_speed() -> float:
	var speed := BASE_SPEED

	match current_state:
		MoveState.WALKING:
			speed *= CROUCH_WALK_SPEED_MODIFIER if is_crouching else WALKING_SPEED_MODIFIER
		MoveState.RUNNING:
			if is_crouching:
				speed *= CROUCH_SPEED_MODIFIER
		MoveState.SPRINTING:
			speed *= SPRINTING_SPEED_MODIFIER

	return speed * speed_multiplier


func is_moving() -> bool:
	var velocity := PlayerManager.character.velocity
	
	return absf(velocity.x) > 0.001 or absf(velocity.z) > 0.001


func is_airborne() -> bool:
	return current_state in [MoveState.JUMPING, MoveState.FALLING]


func is_sprinting() -> bool:
	return current_state == MoveState.SPRINTING


func is_walking() -> bool:
	return current_state == MoveState.WALKING


func _read_input() -> void:
	_move_dir = Input.get_vector("left", "right", "up", "down")
	_jump_pressed = Input.is_action_just_pressed("jump")
	_crouch_pressed = Input.is_action_just_pressed("crouch")
	_sprint_held = Input.is_action_pressed("sprint")
	_walk_held = Input.is_action_pressed("walk")


func _add_gravity(delta: float) -> void:
	if not PlayerManager.character.is_on_floor():
		PlayerManager.character.velocity += PlayerManager.character.get_gravity() * delta * FALL_SPEED


func _handle_actions() -> void:
	if _jump_pressed and PlayerManager.character.is_on_floor() and PlayerManager.stats_handler.has_stamina(JUMP_STAMINA_COST):
		PlayerManager.character.velocity.y = JUMP_FORCE * CROUCH_JUMP_MODIFIER if is_crouching else JUMP_FORCE
		PlayerManager.stats_handler.consume_stamina(JUMP_STAMINA_COST)
	
	if _crouch_pressed and PlayerManager.character.is_on_floor():
		if is_crouching:
			var space_needed = STAND_HEIGHT - PlayerManager.shape.height
			
			if not PlayerManager.character.test_move(PlayerManager.character.transform, Vector3.UP * space_needed):
				is_crouching = false
		else:
			is_crouching = true


func _update_crouch(delta: float) -> void:
	var target_height := CROUCH_HEIGHT if is_crouching else STAND_HEIGHT
	
	PlayerManager.shape.height = lerp(PlayerManager.shape.height, target_height, delta * CROUCH_LERP_SPEED)


func _update_state() -> void:
	if not PlayerManager.character.is_on_floor():
		current_state = MoveState.JUMPING if PlayerManager.character.velocity.y > 0.0 else MoveState.FALLING
		return
	
	if not movement_enabled or GameManager.menu_opened or _move_dir.length_squared() == 0.0:
		current_state = MoveState.IDLE
		return
	
	if _sprint_held and not is_crouching and sprint_enabled and not PlayerManager.stats_handler.is_sprint_blocked():
		current_state = MoveState.SPRINTING
	elif _walk_held:
		current_state = MoveState.WALKING
	else:
		current_state = MoveState.RUNNING


func _apply_movement(delta: float) -> void:
	var direction := (PlayerManager.head.transform.basis * Vector3(_move_dir.x, 0, _move_dir.y)).normalized()
	var speed := current_speed()
	var friction := 10.0 if PlayerManager.character.is_on_floor() else 1.0
	
	PlayerManager.character.velocity.x = lerp(PlayerManager.character.velocity.x, direction.x * speed, delta * friction)
	PlayerManager.character.velocity.z = lerp(PlayerManager.character.velocity.z, direction.z * speed, delta * friction)
