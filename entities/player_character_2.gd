extends CharacterBody3D

signal health_depleted(source)

@onready var head: Node3D = $Head

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var lurch_timer: Timer = $LurchTimer
@onready var slide_boost_cooldown_timer: Timer = $SlideBoostCooldownTimer
@onready var object_interact_ray_cast: RayCast3D = $Head/ObjectInteractRayCast
@onready var gun: Gun1 = $Head/Node3D/Gun1

@export_range(0.1, 500) var walking_acceleration: float = 5
@export_range(0.1, 500) var sprinting_acceleration: float = 5
@export_range(0.1, 500) var crouching_acceleration: float = 5
@export_range(1, 500) var air_acceleration_speed: float
@export_range(0.1, 500) var jump_velocity: float
@export_range(0.1, 500) var lurch_velocity: float

@export_range(0.01, 100) var friction: float
@export_range(0.01, 100) var air_resistance: float

@export_range(0.01, 10) var mouse_sensitivity: = .15

@export_group("Sliding")
@export_range(0.1, 100) var slide_boost_threshold_speed: float
@export_range(0.1, 100) var stop_slide_threshold_speed: float
@export_range(0.1, 500) var slide_boost_velocity: float
@export_range(0.1, 100) var slide_friction: float

var local_direction: = Vector3.ZERO
var direction: = Vector3.ZERO
var was_on_floor_last_frame: = true
var is_sliding: = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Model/AnimationPlayer.play("run-forwards")

func _process(_delta: float) -> void:
	var raw_input: = Input.get_vector("left", "right", "forwards", "backwards")
	local_direction = Vector3(raw_input.x, 0, raw_input.y)
	direction = transform.basis * local_direction

func update(delta: float, frame: int) -> void:
	var acceleration: = direction
	if not is_on_floor():
		if was_on_floor_last_frame:
			lurch_timer.start()
		acceleration *= air_acceleration_speed
		acceleration *= clampf(1 - direction.dot(velocity.normalized()), 0, 1)
		acceleration.y = -gravity
		acceleration += -velocity * air_resistance
	else:
		var current_friction: = friction
		
		if Input.is_action_pressed("crouch"):
			var speed: = velocity.length()
			if is_sliding:
				acceleration += -velocity * slide_friction
				if speed < stop_slide_threshold_speed:
					is_sliding = false
			else:
				var slide_available: = slide_boost_cooldown_timer.is_stopped()
				if slide_available and speed >= slide_boost_threshold_speed:
					print("Slid")
					if speed < slide_boost_velocity:
						velocity = velocity.normalized() * slide_boost_velocity
					acceleration.x = 0
					acceleration.y = 0
					slide_boost_cooldown_timer.start()
					acceleration += -velocity * slide_friction
					is_sliding = true
				else:
					is_sliding = false
					acceleration *= crouching_acceleration
					acceleration += -velocity * friction
		elif local_direction.z < -sqrt(2)/2 and true: #Input.is_action_pressed("sprint"):
			is_sliding = false
			acceleration *= sprinting_acceleration
			acceleration += -velocity * friction
		else:
			acceleration *= walking_acceleration
			is_sliding = false
			acceleration += -velocity * friction
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			lurch_timer.start()
		
		#if acceleration.is_zero_approx():
	velocity += acceleration * delta
	
	move_and_slide()
	
	check_object_interactions()
	if gun and Input.is_action_just_pressed("throw"):
		handle_throw()
	
	was_on_floor_last_frame = is_on_floor()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	elif event.is_action_pressed("left") or event.is_action_pressed("right") \
		or event.is_action_pressed("forwards") or event.is_action_pressed("backwards"):
		handle_lurch()

func handle_lurch() -> void:
	var raw_input: = Input.get_vector("left", "right", "forwards", "backwards")
	local_direction = Vector3(raw_input.x, 0, raw_input.y)
	direction = transform.basis * local_direction
	
	if not is_in_air() or lurch_timer.is_stopped() or direction.is_zero_approx():
		return
	
	var horizontal_velocity: = Vector3(velocity.x, 0, velocity.z)
	var h_vel_magnitude: = horizontal_velocity.length()
	var vertical_velocity: = velocity.y
	var new_horizontal_velocity: = horizontal_velocity + direction * lurch_velocity
	var new_h_vel_magnitude: = new_horizontal_velocity.length()
	if new_h_vel_magnitude > lurch_velocity and new_h_vel_magnitude > h_vel_magnitude:
		var adjusted_magnitude: = maxf(lurch_velocity, h_vel_magnitude * 0.98)
		new_horizontal_velocity = new_horizontal_velocity.normalized() * adjusted_magnitude
	velocity = new_horizontal_velocity + Vector3(0, vertical_velocity, 0)

func check_object_interactions() -> void:
	if Input.is_action_just_pressed("interact") and object_interact_ray_cast.is_colliding():
		var object: Node3D = object_interact_ray_cast.get_collider()
		if not object.is_in_group("interactable"): return
		
		if object is Gun1:
			object.reparent($Head/Node3D)
			object.transform = $Head/Node3D/Marker3D.transform
			object.controlled = true
			object.locally_controlled = true
			object.bullet_source = $Head
			var excluded_colliders: Array[CollisionObject3D] = [$HurtboxComponent]
			object.excluded_colliders = excluded_colliders # TODO
			if gun:
				drop_gun()
			gun = object

func handle_throw() -> void:
	var vel: = Vector3(0, 1, -15)
	gun.global_position = $Head.global_position
	gun.global_rotation = $Head.global_rotation
	gun.position += Vector3.FORWARD * 0.6
	gun.apply_torque_impulse(Vector3(1000, 0, 0))
	drop_gun($Head.global_transform.basis * vel)

func is_in_air() -> bool:
	return not is_on_floor() # and not is_on_wall()

func _on_health_component_health_depleted(source):
	health_depleted.emit(source)

func drop_gun(gun_velocity: Vector3 = Vector3.ZERO) -> void:
	gun.reparent(get_parent_node_3d(), true)
	gun.controlled = false
	gun.locally_controlled = false
	gun.apply_central_impulse(velocity)
	if not gun_velocity.is_zero_approx():
		gun.apply_central_impulse(gun_velocity)
	gun = null
