extends CharacterState

onready var particles = $DeathParticles
onready var respawn_timer: Timer = $RespawnTimer

export var respawn_time: float = 5.0 # In seconds


# Upon entering the state, we set the Player node's velocity to zero.
func enter(msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	character.velocity = Vector2.ZERO
	
	if msg.direction:
		particles.process_material.direction = msg.direction
	if msg.hit_position:
		print(msg.hit_position)
		particles.global_position = msg.hit_position
	particles.emitting = true
	
	character.visible = false
	character.collision_shape.call_deferred('set_disabled', true)
	
	if character.stats.lives > 0:
		respawn_timer.start(respawn_time)


func exit() -> void:
	particles.emitting = false
	character.visible = true
	character.collision_shape.call_deferred('set_disabled', false)


func _on_RespawnTimer_timeout() -> void:
	if is_network_master():
		character.global_position = character.get_level().get_random_spawn_point()
		rpc('update_spawn_position', character.global_position)
	character.stats.lives -= 1
	character.posture = character.Posture.MEDIUM
	character.stats.current_health = character.stats.max_health
	state_machine.transition_to("Air")

puppet func update_spawn_position(_position: Vector2) -> void:
	character.global_position = _position
