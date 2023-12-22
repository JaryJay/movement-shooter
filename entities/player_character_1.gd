extends CharacterBody3D

@onready var head: = $Head

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_range(0.1, 500) var walking_speed: float = 5
@export_range(0.1, 500) var sprinting_speed: float = 5
@export_range(0.1, 500) var crouching_speed: float = 5
@export_range(0.1, 500) var jump_velocity: float = 5
@export_range(0.01, 10) var mouse_sensitivity: = .3

var direction: = Vector3.ZERO

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "forwards", "backwards")
	direction = direction.lerp((transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), .5)
	if not direction.is_zero_approx():
		velocity.x = direction.x * walking_speed
		velocity.z = direction.z * walking_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walking_speed)
		velocity.z = move_toward(velocity.z, 0, walking_speed)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clampf(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
