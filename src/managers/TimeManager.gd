extends Node


signal tod_ready(tod: TimeOfDay)

var tod: TimeOfDay


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is TimeOfDay:
		tod = node
		get_tree().node_added.disconnect(_on_node_added)
		tod_ready.emit(tod)
