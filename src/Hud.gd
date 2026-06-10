extends CanvasLayer


@onready var health_value: Label = $StatsControl/Stats/Value/Health
@onready var mana_value: Label = $StatsControl/Stats/Value/Mana
@onready var stamina_value: Label = $StatsControl/Stats/Value/Stamina


func _ready() -> void:
	if PlayerManager.StatsHandler:
		_connect_stats(PlayerManager.StatsHandler)
	else:
		PlayerManager.stats_handler_ready.connect(_connect_stats)


func _connect_stats(stats: PlayerStatsHandler) -> void:
	stats.health_changed.connect(_on_health_changed)
	stats.mana_changed.connect(_on_mana_changed)
	stats.stamina_changed.connect(_on_stamina_changed)

	health_value.text = str(roundi(stats.current_health))
	mana_value.text = str(roundi(stats.current_mana))
	stamina_value.text = str(roundi(stats.current_stamina))


func _on_health_changed(current: float, _max_value: float) -> void:
	health_value.text = str(roundi(current))


func _on_mana_changed(current: float, _max_value: float) -> void:
	mana_value.text = str(roundi(current))


func _on_stamina_changed(current: float, _max_value: float) -> void:
	stamina_value.text = str(roundi(current))
