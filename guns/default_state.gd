class_name DefaultState extends State

@export var shooting_state: ShootingState

func process(gun: Gun1, delta: float) -> void:
	gun.fire_cooldown = maxf(0, gun.fire_cooldown - delta)
	if gun.locally_controlled and Input.is_action_pressed("shoot") and gun.ammo > 0:
		gun.state_machine.state = shooting_state
