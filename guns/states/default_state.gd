class_name DefaultState extends State

@export var shooting_state: ShootingState
@export var reloading_state: ReloadingState

func process(gun: Gun1, delta: float) -> void:
	gun.fire_cooldown = maxf(0, gun.fire_cooldown - delta)
	if not gun.locally_controlled: return
	
	if Input.is_action_pressed("shoot"):
		if gun.ammo > 0:
			gun.state_machine.state = shooting_state
		else:
			gun.state_machine.state = reloading_state
	elif Input.is_action_just_pressed("reload") and gun.ammo < gun.ammo_capacity:
		gun.state_machine.state = reloading_state
	
