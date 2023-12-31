class_name AiDyingState extends State

var ticks_until_deletion: int = 400

func _enter_state(entity: CharacterBody3D):
	entity.animation_player.play("armed-die")
	var gun: Node3D = entity.gun
	gun.reparent(entity.get_parent_node_3d(), true)
	gun.controlled = false

func process(entity: CharacterBody3D, _delta: float):
	ticks_until_deletion -= 1
	if ticks_until_deletion <= 0:
		entity.queue_free()

func _exit_state(_entity: CharacterBody3D):
	pass

