class_name HealthComponent extends Node

signal health_changed(new, old, source)
signal health_depleted(source)

@export_range(1, 1000) var max_health: int

@onready var health: int = max_health

func change_health(new_health: int, source: int) -> void:
	if health == new_health: return
	
	var old_health: = health
	health = new_health
	health_changed.emit(new_health, old_health, source)
	
	if health <= 0: health_depleted.emit(source)
