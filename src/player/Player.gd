extends CharacterBody3D


@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var MovementHandler: PlayerMovementHandler
var CameraHandler = PlayerCameraHandler


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = GameManager.get_camera_fov()
	
	MovementHandler = PlayerMovementHandler.new(self, head, camera, collision_shape.shape)
	CameraHandler = PlayerCameraHandler.new(self, head, camera)


func _unhandled_input(event: InputEvent) -> void:
	CameraHandler.handle_camera_rotation(event)


func _physics_process(delta: float) -> void:
	MovementHandler.handle_movement(delta)
	CameraHandler.handle_camera_physics(delta, MovementHandler)
