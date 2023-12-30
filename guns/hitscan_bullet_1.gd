extends Node3D

@export var bullet_trail_scene: PackedScene

@export_range(0, 1000) var max_range: int
@export_flags_3d_physics var collision_mask: int

var damage: int
var excluded_colliders: Array[CollisionObject3D]

func update(delta: float, _frame: int = 0):
	var space_state: = get_world_3d().direct_space_state
	var from: = global_position
	var direction: = global_transform.basis * Vector3.FORWARD
	var to: = from + direction * max_range
	var excluded: Array[RID] = []
	for e: CollisionObject3D in excluded_colliders:
		excluded.append(e.get_rid())
	var query: = PhysicsRayQueryParameters3D.create(from, to, collision_mask, excluded)
	query.collide_with_areas = true

	var result: = space_state.intersect_ray(query)
	if result.is_empty():
		queue_free()
		spawn_trail(to)
		return
	var collider: Object = result.collider
	spawn_trail(result.position)
	if collider is HurtboxComponent:
		collider.take_damage(damage, get_instance_id())
		#print("Dealt damage to %s" % collider)
		#print(collider.get_parent())
	
	queue_free()

func spawn_trail(to: Vector3) -> void:
	var trail: Node3D = bullet_trail_scene.instantiate()
	trail.position = global_position
	trail.rotation = global_rotation
	trail.scale.z = trail.position.distance_to(to)
	get_tree().root.add_child(trail)
