extends CharacterState

onready var barrier = $Barrier

func enter(_msg := {}) -> void:
	update_position()
	character.animation_state.travel("block")
	barrier.enable()
	
func physics_update(_delta: float) -> void:
	character.animation_tree.set('parameters/block/blend_position', character.get_posture())
	update_position()
	# When we release the block associated button, we want to disable the barrier and transition 
	# to the idle state.
	if Input.is_action_just_released("block"):
		barrier.disable()
		state_machine.transition_to("Idle")

func update_position():
	# Update the position of the barrier to the casting position. Set the scale to the facing direction
	# of the player.
	barrier.position = character.cast_position.position
	barrier.sprite.scale.x = character.facing_direction


func _on_Barrier_area_entered(area):
	barrier.disable()
	character.animation_state.travel("recoil")
