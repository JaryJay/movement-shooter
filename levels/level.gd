class_name Level extends Node3D

## The current frame number in the game.
var frame: int = 0
## Equal to frame + 1 if no frames are desynced.
var earliest_desynced_frame: int = 1

#region Player-only variables

## Integer between 0 and 5, inclusive, representing the team that the local
## player controls. This value is set once in _ready(), and doesn't change.
var controlled_team: int = 0
## Filled by [method _unhandled_input()] as well as entities with UIWheels and
## emptied by [method _physics_process()]. Inputs are sent to the server at a
## rate of one per frame.
## Additionally, inputs in this queue do not have their [code]frame[/code] set.
var local_input_queue: Array[ClientInput] = []

var is_spectator: = false

#endregion

## Updates the frame count, handles client input, and calls
## [method rollback_and_resimulate].
func _physics_process(delta: float) -> void:
	frame += 1
	
	if not is_spectator:
		# Note that detecting inputs is not the same as handling them
		var input: ClientInput = _detect_input()
		_add_input(input)
	
	# Handle inputs from all players, including the local player
	rollback_and_resimulate(delta)

func _detect_input() -> ClientInput:
	return ClientInput.new(frame, true)

## Resets the game state back to the earliest desynced frame, then resimulates
## those desynced frames.
## Sets [member earliest_desynced_frame] to [code]frame + 1[/code].
func rollback_and_resimulate(delta: float) -> void:
	# Rollback
	if earliest_desynced_frame < frame:
		# NOTE: Always remember to add a few lines here every time we add a new
		# type of game object that needs rollbacking
		pass
		#for player: Player in get_tree().get_nodes_in_group("players"):
			#player.return_to_frame_state(earliest_desynced_frame - 1)
		#for building: Building in get_tree().get_nodes_in_group("buildings"):
			#building.return_to_frame_state(earliest_desynced_frame - 1)
		#for squad: Squad in get_tree().get_nodes_in_group("squads"):
			#squad.return_to_frame_state(earliest_desynced_frame - 1)
	
	# Handle inputs
	for f in range(earliest_desynced_frame, frame + 1):
		pass
		## Handle inputs from all players
		#for player_id in Server.lobby.player_ids:
			#for input in player_inputs[player_id]:
				#if input.frame == f:
					#_handle_input(input)
					#break
		#
		## Update everything
		for e: Node in get_tree().get_nodes_in_group("entities"):
			e.update(delta, f)
		for e: Node in get_tree().get_nodes_in_group("bullets"):
			e.update(delta, f)
		#for e: Building in get_tree().get_nodes_in_group("buildings"):
			#e.update(f)
		#for e: Squad in get_tree().get_nodes_in_group("squads"):
			#e.update(f)
		#
		## Post update everything
		#for e: Player in get_tree().get_nodes_in_group("players"):
			#e.post_update(f)
		#for e: Building in get_tree().get_nodes_in_group("buildings"):
			#e.post_update(f)
		#for e: Squad in get_tree().get_nodes_in_group("squads"):
			#e.post_update(f)
	
	earliest_desynced_frame = frame + 1

func _add_input(input: ClientInput) -> void:
	pass

func _handle_input(input: ClientInput) -> void:
	if input.is_empty: return
	pass

func _on_character_2_health_depleted(source):
	print("Bro you're bad")
	$Entities/Character2/Head/Camera3D.reparent(self, true)
	$Entities/Character2.queue_free()
