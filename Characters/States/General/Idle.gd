#Idle.gd
extends CharacterState


# Upon entering the state, we set the Player node's velocity to zero.
func enter(msg := {}) -> void:
	character.animation_state.travel('idle')
	character.velocity = Vector2.ZERO


func physics_update(_delta: float) -> void:
	character.animation_tree.set('parameters/idle/blend_position', character.get_posture())
	# If you have platforms that break when standing on them, you need that check for 
	# the character to fall.
	if not character.is_on_floor():
		state_machine.transition_to("Air")
		return

	if character.is_network_master():
		if not character.is_invincible():
			if Input.is_action_pressed("block"):
				state_machine.transition_to("Block")
				return
			if Input.is_action_pressed("attack"):
				state_machine.transition_to(character.attack_state_name)
				return
			if Input.is_action_just_pressed("special_1"):
				state_machine.transition_to(character.special_a_state_name)
				return
			if Input.is_action_just_pressed("special_2"):
				state_machine.transition_to(character.special_b_state_name)
				return
		if Input.is_action_just_pressed("jump"):
			state_machine.transition_to("Air", {do_jump = true})
			return
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			state_machine.transition_to("Run")
			return
