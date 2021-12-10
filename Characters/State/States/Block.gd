extends CharacterState

onready var barrier = $Barrier

func enter(_msg := {}) -> void:
	update_position()
	barrier.enable()
	
func physics_update(_delta: float) -> void:
	# When we release the block associated button, we want to disable the barrier and transition 
	# to the idle state.
	if Input.is_action_just_released("move_2"):
		barrier.disable()
		state_machine.transition_to("Idle")
	else:
		character.animationPlayer.play("block_" + character.get_posture_suffix())
		update_position()

func update_position():
	# Update the position of the barrier to the casting position. Set the scale to the facing direction
	# of the player.
	barrier.global_transform = character.castPosition.global_transform
	barrier.sprite.scale.x = character.facing_direction

	
