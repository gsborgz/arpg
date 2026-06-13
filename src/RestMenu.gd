class_name RestMenu
extends CanvasLayer


signal confirmed(hours: int)
signal cancelled

@onready var hours_input: SpinBox = $Panel/Margin/VBox/HoursRow/HoursInput
@onready var confirm_button: Button = $Panel/Margin/VBox/Buttons/Confirm
@onready var cancel_button: Button = $Panel/Margin/VBox/Buttons/Cancel


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm)
	cancel_button.pressed.connect(_on_cancel)
	hide()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("rest"):
		get_viewport().set_input_as_handled()
		_on_cancel()


func open() -> void:
	hours_input.value = 8
	show()


func _on_confirm() -> void:
	hide()
	confirmed.emit(int(hours_input.value))


func _on_cancel() -> void:
	hide()
	cancelled.emit()
