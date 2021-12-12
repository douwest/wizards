extends CharacterState

onready var barrier = $Barrier

func enter(_msg := {}) -> void:
	update_position()
	barrier.enable()
	character.animation_state.travel("block")		
	
func physics_update(_delta: float) -> void:
	character.animation_tree.set('parameters/block/blend_position', character.get_posture())
	# When we release the block associated button, we want to disable the barrier and transition 
	# to the idle state.
	if Input.is_action_just_released("move_2"):
		barrier.disable()
		state_machine.transition_to("Idle")
	else:
		update_position()

func update_position():
	# Update the position of the barrier to the casting position. Set the scale to the facing direction
	# of the player.
	barrier.global_transform = character.castPosition.global_transform
	barrier.sprite.scale.x = character.facing_direction

	
