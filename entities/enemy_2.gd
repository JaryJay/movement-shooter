extends CharacterBody3D

@onready var animation_player: = $Model/AnimationPlayer
@onready var gun: = $BoneAttachment3D/Gun1
@onready var state_machine: StateMachine = $StateMachine

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	state_machine.initialize()

func update(delta: float, _frame: int) -> void:
	state_machine.process_state(delta)
	
	var acceleration: Vector3 = Vector3.ZERO
	if not is_on_floor():
		acceleration.y = -gravity
	velocity += acceleration * delta
	move_and_slide()

func _on_health_component_health_changed(new: int, old: int, _source):
	if is_alive() and new < old:
		animation_player.play("armed-take-damage")

func _on_health_component_health_depleted(source):
	state_machine.state = $StateMachine/AiDyingState

func is_alive() -> bool:
	return not state_machine.state is AiDyingState
