class_name ReloadingState extends State

@export var default_state: DefaultState

@export_range(0, 600) var reload_wait_time: int = 144
var reload_time_left: int

func _enter_state(gun: Gun1) -> void:
	gun.animation_player.play("reload")
	reload_time_left = reload_wait_time

func process(gun: Gun1, delta: float) -> void:
	reload_time_left -= 1
	if reload_time_left <= 0:
		gun.state_machine.state = default_state

func _exit_state(gun: Gun1) -> void:
	gun.ammo = gun.ammo_capacity
