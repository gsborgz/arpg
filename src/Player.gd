extends CharacterBody3D


@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = GameManager.camera_config.fov
	
	PlayerManager.head = head
	PlayerManager.camera = camera
	PlayerManager.shape = collision_shape.shape
	PlayerManager.character = self
	PlayerManager.StatsHandler = PlayerStatsHandler.new()
	PlayerManager.MovementHandler = PlayerMovementHandler.new()
	PlayerManager.CameraHandler = PlayerCameraHandler.new()


func _unhandled_input(event: InputEvent) -> void:
	PlayerManager.CameraHandler.handle_camera_rotation(event)


func _physics_process(delta: float) -> void:
	PlayerManager.MovementHandler.handle_movement(delta)
	PlayerManager.CameraHandler.handle_camera_physics(delta)
