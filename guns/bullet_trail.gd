extends Node3D

@export_range(0.001, 10) var lifespan: float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.wait_time = lifespan

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$MeshInstance3D.transparency = 1 - $Timer.time_left / lifespan
