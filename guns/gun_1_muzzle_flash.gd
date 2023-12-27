extends Node3D

func _ready() -> void:
	for node: Node in get_children():
		if node is GPUParticles3D:
			node.emitting = true
	rotate_z(randf_range(0, 2 * PI))
