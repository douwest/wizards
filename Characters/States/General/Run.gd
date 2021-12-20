# Run.gd
extends CharacterState

func enter(_msg := {}):
	character.animation_state.travel("run")


func physics_update(_delta: float) -> void:
	character.animation_tree.set('parameters/run/blend_position', character.get_posture())
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not character.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	if character.is_network_master():
		var direction := character.get_direction() as Vector2
		character.velocity = character.calculate_move_velocity(character.velocity, direction, character.speed, Input.is_action_just_released("jump") and character.velocity.y < 0.0)	
		character.velocity = character.move_and_slide_with_snap(character.velocity, character.calculate_snap_vector(direction.y), character.FLOOR_NORMAL, false, 4, 0.9, false)

		if Input.is_action_pressed("block"):
			state_machine.transition_to("Block")
		elif Input.is_action_pressed("attack"):
			state_machine.transition_to(character.attack_state_name)
		elif Input.is_action_just_pressed("special_1"):
			state_machine.transition_to(character.special_a_state_name)
		elif Input.is_action_just_pressed("special_2"):
			state_machine.transition_to(character.special_b_state_name)
		elif Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Air", {do_jump = true})
		elif character.is_stopped():
			state_machine.transition_to("Idle")
