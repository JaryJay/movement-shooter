extends Node3D

@onready var animation_player: = $Model/AnimationPlayer
@onready var gun: = $BoneAttachment3D/Gun1

@onready var ticks: = randi_range(0, 999)

func _ready() -> void:
	animation_player.play("armed-idle")


func update(_delta: float, _frame: int) -> void:
	ticks += 1
	if ticks == 1000:
		gun.shoot_bullet()
		ticks = randi_range(0, 20)

func _on_health_component_health_depleted(source):
	queue_free()
