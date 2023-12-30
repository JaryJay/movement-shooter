extends Node3D

@export_range(0, 500) var damage: int

var excluded_colliders: Array[CollisionObject3D]

@onready var ray_cast: RayCast3D = $RayCast3D
var velocity: Vector3 = Vector3(0, 0, -100)

func _ready():
	for e in excluded_colliders:
		ray_cast.add_exception(e)

func update(delta: float, _frame: int = 0):
	global_position += (transform.basis * velocity) * delta
	if ray_cast.is_colliding():
		if ray_cast.get_collider() is HurtboxComponent:
			var hitbox: HurtboxComponent = ray_cast.get_collider()
			hitbox.take_damage(damage, get_instance_id())
		queue_free()
