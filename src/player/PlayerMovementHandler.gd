class_name PlayerMovementHandler
extends RefCounted

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
const JUMP_VELOCITY: float = 4.5
const CROUCH_JUMP_MODIFIER: float = 0.8
const STAND_HEIGHT: float = 2.0
const CROUCH_HEIGHT: float = 0.5

var character: CharacterBody3D
var head: Node3D
var camera: Camera3D
var collision_shape: CapsuleShape3D

var movement_enabled: bool = true
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

var is_crouching: bool = false:
	set(value):
		is_crouching = value
		if collision_shape:
			collision_shape.height = CROUCH_HEIGHT if value else STAND_HEIGHT


func _init(_character: CharacterBody3D, _head: Node3D, _camera: Camera3D, _collision_shape: CapsuleShape3D) -> void:
	character = _character
	head = _head
	camera = _camera
	collision_shape = _collision_shape


func handle_movement(delta: float) -> void:
	_read_input()
	_add_gravity(delta)
	_update_state()

	if movement_enabled and not GameManager.menu_opened:
		_handle_jump()
		_handle_crouch()
		_apply_movement(delta)
	else:
		character.velocity.x = 0.0
		character.velocity.z = 0.0

	character.move_and_slide()


func current_speed() -> float:
	var speed := BASE_SPEED
	
	match current_state:
		MoveState.WALKING:
			speed *= WALKING_SPEED_MODIFIER
		MoveState.SPRINTING:
			speed *= SPRINTING_SPEED_MODIFIER
	
	if is_crouching:
		speed *= CROUCH_SPEED_MODIFIER
	
	return speed * speed_multiplier


func is_moving() -> bool:
	return not Vector2(character.velocity.x, character.velocity.z).is_zero_approx()


func is_airborne() -> bool:
	return current_state == MoveState.JUMPING or current_state == MoveState.FALLING


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
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta


func _handle_crouch() -> void:
	if _crouch_pressed and character.is_on_floor():
		is_crouching = !is_crouching


func _handle_jump() -> void:
	if _jump_pressed and character.is_on_floor():
		character.velocity.y = JUMP_VELOCITY * CROUCH_JUMP_MODIFIER if is_crouching else JUMP_VELOCITY


func _update_state() -> void:
	if not character.is_on_floor():
		current_state = MoveState.JUMPING if character.velocity.y > 0.0 else MoveState.FALLING
		return

	if not movement_enabled or GameManager.menu_opened:
		current_state = MoveState.IDLE
		return

	if _move_dir.length_squared() == 0.0:
		current_state = MoveState.IDLE
		return

	if _sprint_held and not is_crouching:
		current_state = MoveState.SPRINTING
	elif _walk_held:
		current_state = MoveState.WALKING
	else:
		current_state = MoveState.RUNNING


func _apply_movement(delta: float) -> void:
	var direction := (head.transform.basis * Vector3(_move_dir.x, 0, _move_dir.y)).normalized()
	var speed := current_speed()
	var friction := 10.0 if character.is_on_floor() else 1.0

	character.velocity.x = lerp(character.velocity.x, direction.x * speed, delta * friction)
	character.velocity.z = lerp(character.velocity.z, direction.z * speed, delta * friction)
