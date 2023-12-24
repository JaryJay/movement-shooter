extends CharacterBody3D

@onready var head: = $Head

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var lurch_timer: = $LurchTimer

@export_range(0.1, 500) var walking_acceleration: float = 5
@export_range(0.1, 500) var sprinting_acceleration: float = 5
@export_range(0.1, 500) var crouching_acceleration: float = 5
@export_range(1, 500) var air_acceleration_speed: float
@export_range(0.1, 500) var jump_velocity: float
@export_range(0.1, 500) var lurch_velocity: float

@export_range(0.01, 100) var friction: float
@export_range(0.01, 100) var air_resistance: float

@export_range(0.01, 10) var mouse_sensitivity: = .2

var local_direction: = Vector3.ZERO
var direction: = Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	var raw_input: = Input.get_vector("left", "right", "forwards", "backwards")
	local_direction = Vector3(raw_input.x, 0, raw_input.y)
	direction = transform.basis * local_direction

func _physics_process(delta: float):
	var previous_direction: = direction
	
	var acceleration: = direction
	if not is_on_floor():
		acceleration *= air_acceleration_speed
		acceleration.y = -gravity
		acceleration += -velocity * air_resistance
	else:
		if local_direction.z < -sqrt(2)/2 and Input.is_action_pressed("sprint"):
			acceleration *= sprinting_acceleration
		elif Input.is_action_pressed("crouch"):
			acceleration *= crouching_acceleration
		else:
			acceleration *= walking_acceleration
		
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
			lurch_timer.start()
		
		#if acceleration.is_zero_approx():
		acceleration += -velocity * friction
	velocity += acceleration * delta
	
	move_and_slide()

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
		var adjusted_magnitude: = maxf(lurch_velocity, h_vel_magnitude * 0.9)
		new_horizontal_velocity = new_horizontal_velocity.normalized() * adjusted_magnitude
	velocity = new_horizontal_velocity + Vector3(0, vertical_velocity, 0)

func is_in_air() -> bool:
	return not is_on_floor() # and not is_on_wall()
