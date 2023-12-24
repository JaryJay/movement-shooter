class_name ShootingState extends State

@export var default_state: DefaultState

func process(gun: Gun1, delta: float) -> void:
	if gun.ammo <= 0:
		print("no ammo")
		gun.state_machine.state = default_state
	
	if Input.is_action_pressed("shoot"):
		if gun.fire_cooldown < 0:
			gun.shoot_bullet()
			gun.ammo -= 1
			gun.fire_cooldown += gun.fire_cooldown_time - delta
		else:
			gun.fire_cooldown -= delta
	else:
		gun.state_machine.state = default_state
