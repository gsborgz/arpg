class_name PlayerRestHandler


const REST_ANIMATION_DURATION: float = 2.0

var _is_resting: bool = false


func setup() -> void:
	PlayerManager.rest_menu.confirmed.connect(_on_confirmed)
	PlayerManager.rest_menu.cancelled.connect(_on_cancelled)


func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("rest") and not GameManager.menu_opened and not _is_resting:
		GameManager.menu_opened = true
		PlayerManager.rest_menu.open()


func _on_confirmed(hours: int) -> void:
	GameManager.menu_opened = false
	PlayerManager.movement_handler.movement_enabled = false
	
	if not TimeManager.tod:
		PlayerManager.movement_handler.movement_enabled = true
		return
	
	_is_resting = true
	
	var tod := TimeManager.tod
	var real_seconds_per_hour := (tod.minutes_per_day * 60.0) / 24.0
	
	PlayerManager.stats_handler.time_scale = (hours * real_seconds_per_hour) / REST_ANIMATION_DURATION
	
	var target_time := tod.current_time + hours
	var tween := PlayerManager.character.create_tween()
	
	tween.tween_property(tod, "current_time", target_time, REST_ANIMATION_DURATION)
	tween.tween_callback(func() -> void:
		PlayerManager.movement_handler.movement_enabled = true
		PlayerManager.stats_handler.time_scale = 1.0
		_is_resting = false
	)


func _on_cancelled() -> void:
	GameManager.menu_opened = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
