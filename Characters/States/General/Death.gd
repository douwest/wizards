extends CharacterState

onready var particles = $DeathParticles
onready var respawn_timer: Timer = $RespawnTimer

export var respawn_time: float = 5.0 # In seconds


# Upon entering the state, we set the Player node's velocity to zero.
func enter(msg := {}) -> void:

	if msg.has("direction"):
		particles.process_material.direction = msg.direction
	if msg.has("hit_position"):
		particles.global_position = msg.hit_position
		
	particles.emitting = true
	
	character.velocity = Vector2.ZERO
	character.animation_tree.active = false
	character.effects_animation_player.play("death")
	
	if character.stats.lives > 0:
		respawn_timer.start(respawn_time)


func physics_update(delta: float) -> void:
	if not character.is_on_floor():
		var direction := character.get_direction()

		character.velocity.y = character.calculate_move_velocity(character.velocity, direction, character.speed, Input.is_action_just_released("jump") and character.velocity.y < 0.0).y
		character.velocity = character.move_and_slide(character.velocity, character.FLOOR_NORMAL)
	else:
		character.collision_shape.call_deferred('set_disabled', true)
		


func _on_RespawnTimer_timeout() -> void:
	# Set physics process to false to update the spawn position without having
	# the position be interpolated by the update_puppet function.
	character.visible = false
	character.effects_animation_player.stop()
	character.set_physics_process(false)
	
	# The new spawn point is random, therefore it should only be determined by the master of this character,
	# Otherwise, clients may get another spawn point then the owner of the character.
	# However, the puppets should be informed of the new position.
	if is_network_master():
		character.global_position = character.get_parent().get_random_spawn_point()
		rpc('update_spawn_position', character.global_position)
		
	character.stats.lives -= 1
	character.posture = character.Posture.MEDIUM
	character.stats.current_health = character.stats.max_health
	
	character.set_physics_process(true)
	character.animation_tree.active = true
	character.collision_shape.call_deferred('set_disabled', false)
	character.visible = true
	
	# Transition to the Air state so we do not have to be perfectly on the floor when spawning.
	state_machine.transition_to("Air", {invincible = 3.0})


puppet func update_spawn_position(_position: Vector2) -> void:
	character.global_position = _position
