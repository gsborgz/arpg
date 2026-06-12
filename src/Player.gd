extends CharacterBody3D


@onready var head: Node3D = $Head
@onready var spring_arm: SpringArm3D = $Head/SpringArm3D
@onready var camera: Camera3D = $Head/SpringArm3D/Camera3D
@onready var mesh: Node3D = $Character
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = GameManager.camera_config.fov

	PlayerManager.head = head
	PlayerManager.spring_arm = spring_arm
	PlayerManager.camera = camera
	PlayerManager.mesh = mesh
	PlayerManager.shape = collision_shape.shape
	PlayerManager.character = self
	PlayerManager.stats_handler = PlayerStatsHandler.new()
	PlayerManager.movement_handler = PlayerMovementHandler.new()
	PlayerManager.camera_handler = PlayerCameraHandler.new()


func _unhandled_input(event: InputEvent) -> void:
	PlayerManager.camera_handler.handle_camera_input(event)


func _physics_process(delta: float) -> void:
	PlayerManager.movement_handler.handle_movement(delta)
	PlayerManager.camera_handler.handle_camera_physics(delta)
