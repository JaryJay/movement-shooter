class_name AiHostileState extends State

var ticks: int

func _enter_state(entity: CharacterBody3D):
	entity.animation_player.play("armed-idle")
	ticks = randi_range(0, 400)

func process(entity: CharacterBody3D, _delta):
	ticks += 1
	if ticks == 500:
		entity.gun.shoot_bullet()
		ticks = randi_range(0, 20)

func _exit_state(_entity: CharacterBody3D):
	pass
