@tool
class_name HitboxComponent extends Area3D

@export var health_component: HealthComponent

func _enter_tree() -> void:
	if collision_layer == 1 and collision_mask == 1:
		collision_layer = 0
		collision_mask = 0
		set_collision_layer_value(6, true)

func take_damage(damage: int, source: int) -> void:
	if health_component:
		health_component.change_health(health_component.health - damage, source)
	else:
		printerr("No health component attached.")
