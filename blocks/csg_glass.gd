extends CSGBox3D

func _ready() -> void:
	var collision_shape: CollisionShape3D = $HurtboxComponent/CollisionShape3D
	var shape: = collision_shape.shape.duplicate() as BoxShape3D
	collision_shape.shape = shape
	shape.size = size
	shape.size.z += 0.01

func _on_health_component_health_depleted(source):
	queue_free()
