extends CharacterBody3D

@onready var head: = $Head

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_range(1, 500) var ground_acceleration_speed: float = 10
@export_range(1, 500) var air_acceleration_speed: float

@export_range(0.1, 500) var walking_speed: float = 5
@export_range(0.1, 500) var sprinting_speed: float = 5
@export_range(0.1, 500) var crouching_speed: float = 5
@export_range(0.1, 500) var jump_velocity: float

@export_range(0.01, 100) var friction: float
@export_range(0.01, 100) var air_friction: float

@export_range(0.01, 10) var mouse_sensitivity: = .2

var direction: = Vector3.ZERO
var acceleration: = Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):
	var input_dir: Vector2 = Input.get_vector("left", "right", "forwards", "backwards")
	acceleration = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if not is_on_floor():
		acceleration *= air_acceleration_speed
		acceleration.y = -gravity
		acceleration += -velocity * air_friction
	else:
		acceleration *= ground_acceleration_speed
		acceleration += -velocity * friction
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	velocity += acceleration * delta
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
