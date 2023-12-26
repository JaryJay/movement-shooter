extends Node3D

@onready var animation_player: = $Model/AnimationPlayer

func _ready() -> void:
	animation_player.play("armed-idle")
