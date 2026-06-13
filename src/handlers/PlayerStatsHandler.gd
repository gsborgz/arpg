class_name PlayerStatsHandler


signal health_changed(current: float, max_value: float)
signal mana_changed(current: float, max_value: float)
signal stamina_changed(current: float, max_value: float)

const DEPLETED_COOLDOWN: float = 5.0
const RECOVERY_DELAY: float = 2.0
const REGEN_RATE: float = 2.0
const DRAIN_RATE: float = 6.0
const HEALTH_REGEN_RATE: float = 2.0
const MANA_REGEN_RATE: float = 2.0

# TODO: valores base dos stats devem depender de calculo com base nos atributos do personagem
const BASE_HEALTH: float = 50
const BASE_MANA: float = 50
const BASE_STAMINA: float = 50

var current_health: float = BASE_HEALTH
var current_mana: float = BASE_MANA
var current_stamina: float = BASE_STAMINA

var time_scale: float = 1.0

var _depleted_cooldown_timer: float = 0.0
var _recovery_delay_timer: float = 0.0
var _was_draining: bool = false


func update_current_health(value: float) -> void:
	current_health = clamp(current_health + value, 0, BASE_HEALTH)
	health_changed.emit(current_health, BASE_HEALTH)


func update_current_mana(value: float) -> void:
	current_mana = clamp(current_mana + value, 0, BASE_MANA)
	mana_changed.emit(current_mana, BASE_MANA)


func process_stamina(delta: float, is_draining: bool) -> void:
	var prev_stamina := current_stamina

	if is_draining:
		current_stamina = clamp(current_stamina - DRAIN_RATE * delta, 0.0, BASE_STAMINA)
		_was_draining = true
	else:
		if _was_draining:
			_was_draining = false
			if current_stamina == 0.0:
				_depleted_cooldown_timer = DEPLETED_COOLDOWN
			else:
				_recovery_delay_timer = RECOVERY_DELAY

		if _depleted_cooldown_timer > 0.0:
			_depleted_cooldown_timer -= delta * time_scale
		elif _recovery_delay_timer > 0.0:
			_recovery_delay_timer -= delta * time_scale
		else:
			current_stamina = clamp(current_stamina + REGEN_RATE * time_scale * delta, 0.0, BASE_STAMINA)

	if current_stamina != prev_stamina:
		stamina_changed.emit(current_stamina, BASE_STAMINA)

	if time_scale > 1.0:
		if current_health < BASE_HEALTH:
			update_current_health(HEALTH_REGEN_RATE * time_scale * delta)
		if current_mana < BASE_MANA:
			update_current_mana(MANA_REGEN_RATE * time_scale * delta)


func consume_stamina(amount: float) -> void:
	current_stamina = clamp(current_stamina - amount, 0.0, BASE_STAMINA)
	stamina_changed.emit(current_stamina, BASE_STAMINA)
	if current_stamina == 0.0:
		_depleted_cooldown_timer = DEPLETED_COOLDOWN
	else:
		_recovery_delay_timer = RECOVERY_DELAY


func has_stamina(amount: float) -> bool:
	return current_stamina >= amount and _depleted_cooldown_timer <= 0.0


func is_sprint_blocked() -> bool:
	return current_stamina == 0.0 or _depleted_cooldown_timer > 0.0
