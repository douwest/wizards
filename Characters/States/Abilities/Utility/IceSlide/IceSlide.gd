extends AbilityState

export var slide_friction = 0.05
export var ice_spawn_distance = 24

onready var particle_factory = $ParticleFactory

var old_friction = 0.275
var old_speed = 525.0

func enter(_msg := {}) -> void:
	particle_factory.create_new(character.global_position + character.facing_direction * ice_spawn_distance)
	old_speed = character.speed.x
	old_friction = character.friction
	character.friction = slide_friction
	character.speed.x += 100
	character.animation_tree.set('parameters/idle/blend_position', character.Posture.LOW)	
	character.animation_state.travel("block")

func physics_update(delta: float) -> void:
	particle_factory.create_new(character.global_position + character.facing_direction * ice_spawn_distance)
	if not character.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	if character.is_network_master():
		
		if character.is_stopped() or not Input.is_action_pressed("special_1"):
			state_machine.transition_to("Idle")
			return
		
		var direction := character.get_direction() as Vector2
		character.velocity = character.calculate_move_velocity(character.velocity, direction, character.speed, Input.is_action_just_released("jump") and character.velocity.y < 0.0)	
		character.velocity = character.move_and_slide_with_snap(character.velocity, character.calculate_snap_vector(direction.y), character.FLOOR_NORMAL, false, 4, 0.9, false)
		
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

func exit() -> void:
	character.friction = old_friction
	character.speed.x = old_speed
