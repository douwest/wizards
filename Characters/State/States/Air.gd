# Air.gd
extends CharacterState


# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("do_jump"):
		character.velocity.y = -character.speed.y


func physics_update(_delta: float) -> void:
	character.animation_state.travel('jump' if character.velocity.y <= 0 else 'falling')
	# Horizontal movement.
	var direction := character.get_direction()

	character.velocity.y = character.calculate_move_velocity(character.velocity, direction, character.speed, Input.is_action_just_released("jump") and character.velocity.y < 0.0).y
	character.velocity = character.move_and_slide(character.velocity, character.FLOOR_NORMAL)

	# Landing.
	if character.is_on_floor():
		if character.is_stopped():
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
	
		
