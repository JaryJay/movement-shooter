class_name Gun1 extends RigidBody3D

@export var bullet_source: Node3D
@export var locally_controlled: = false

@export_range(0.01, 10) var fire_cooldown_time: float
@export_range(0, 200) var ammo_capacity: int
@export_range(0, 200) var damage: int
@export var excluded_colliders: Array[CollisionObject3D]

@export var muzzle_flash_scene: PackedScene
@export var bullet_scene: PackedScene

@onready var state_machine: = $StateMachine
@onready var animation_player: = $AnimationPlayer

var trigger_held: = false
@onready var ammo: = ammo_capacity
@onready var fire_cooldown: = fire_cooldown_time
@onready var muzzle_flash_source: = $Pivot/MuzzleFlashSource
@onready var audio_stream_player: = $Pivot/AudioStreamPlayer3D

var controlled: = true : set = _set_controlled

func _ready() -> void:
	if not bullet_source:
		printerr("gun_1.gd: You forgot to set the bullet source.")
	state_machine.initialize()
	if locally_controlled:
		audio_stream_player.panning_strength = 0
		$Crosshair.show()

func _physics_process(delta: float) -> void:
	state_machine.process_state(delta)

func shoot_bullet() -> void:
	animation_player.stop(true)
	animation_player.play("shoot", 0.01)
	var muzzle_flash: = muzzle_flash_scene.instantiate()
	muzzle_flash_source.add_child(muzzle_flash)
	audio_stream_player.play()
	
	var bullet: Node3D = bullet_scene.instantiate()
	bullet.damage = damage
	bullet.global_transform = bullet_source.global_transform
	bullet.excluded_colliders = excluded_colliders
	get_tree().get_first_node_in_group("entities_parent").add_child(bullet)

func _set_controlled(value: bool) -> void:
	controlled = value
	freeze = controlled
	if controlled:
		remove_from_group("interactable")
	else:
		add_to_group("interactable")
