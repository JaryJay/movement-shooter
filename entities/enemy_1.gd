extends CharacterBody3D

@onready var animation_player: = $character_2/AnimationPlayer

func _ready() -> void:
	animation_player.play("run-forwards")
