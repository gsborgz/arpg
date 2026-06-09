class_name PlayerMovementHandler

const WALKING_SPEED: float = 0.5
const JOGGING_SPEED: float = 5.0
const SPRINTING_SPEED: float = 8.0
const JUMP_VELOCITY: float = 4.5
const STAND_HEIGHT: float = 2.0
const CROUCH_HEIGHT: float = 0.5
const CROUCH_SPEED_MODIFIER: float = 0.4
const CROUCH_JUMP_MODIFIER: float = 0.8

var character: CharacterBody3D
var head: Node3D
var camera: Camera3D
var collision_shape: CapsuleShape3D
var speed: float
var is_sprinting: bool = false
var is_moving: bool = false
var is_crouching: bool = false
var is_walking: bool = false


func _init(_character: CharacterBody3D, _head: Node3D, _camera: Camera3D, _collision_shape: CapsuleShape3D) -> void:
	character = _character
	head = _head
	camera = _camera
	collision_shape = _collision_shape


func handle_movement(delta: float) -> void:
	if GameManager.menu_opened():
		return
	
	_add_gravity(delta)
	_handle_jump()
	_handle_move_speed()
	_handle_crouch()
	_handle_movement(delta)
	
	character.move_and_slide()


func _add_gravity(delta: float) -> void:
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta


func _handle_crouch() -> void:
	if Input.is_action_just_pressed("crouch") and character.is_on_floor():
		is_crouching = !is_crouching
	
	if is_crouching:
		collision_shape.height = CROUCH_HEIGHT
	else:
		collision_shape.height = STAND_HEIGHT


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and character.is_on_floor():
		character.velocity.y = JUMP_VELOCITY * CROUCH_JUMP_MODIFIER if is_crouching else JUMP_VELOCITY


func _handle_move_speed() -> void:
	if Input.is_action_pressed("sprint") and character.is_on_floor() and !is_crouching:
		speed = SPRINTING_SPEED 
		is_sprinting = true
	elif Input.is_action_pressed("walk") and character.is_on_floor():
		speed = WALKING_SPEED
		is_sprinting = false
	else:
		speed = JOGGING_SPEED * CROUCH_SPEED_MODIFIER if is_crouching else JOGGING_SPEED
		is_sprinting = false


func _handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if character.is_on_floor():
		if direction:
			character.velocity.x = direction.x * speed
			character.velocity.z = direction.z * speed
			
			is_moving = true
		else:
			character.velocity.x = lerp(character.velocity.x, direction.x * speed, delta * 8.0)
			character.velocity.z = lerp(character.velocity.z, direction.z * speed, delta * 8.0)
			
			is_moving = false
	else:
		character.velocity.x = lerp(character.velocity.x, direction.x * speed, delta * 1.0)
		character.velocity.z = lerp(character.velocity.z, direction.z * speed, delta * 1.0)
