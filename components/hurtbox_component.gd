@tool
class_name HurtboxComponent extends Area3D

@export var health_component: HealthComponent
@export_range(0, 20) var damage_multiplier: float = 1.0

func _enter_tree() -> void:
	if not Engine.is_editor_hint(): return
	if collision_layer == 1 and collision_mask == 1:
		collision_layer = 0
		collision_mask = 0
		set_collision_layer_value(6, true)

func take_damage(damage: int, source: int) -> void:
	if health_component:
		var new_health: = health_component.health - damage * damage_multiplier
		health_component.change_health(new_health, source)
	else:
		printerr("No health component attached.")
