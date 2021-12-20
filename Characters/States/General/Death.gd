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
		particles.position = msg.hit_position
	particles.emitting = true
	
	character.visible = false
	character.controllable = false
	
	if character.stats.lives > 0:
		respawn_timer.start(respawn_time)


func _on_RespawnTimer_timeout():
	character.stats.lives -= 1
	character.posture = character.Posture.MEDIUM
	character.global_position = Vector2.ZERO
	character.stats.current_health = character.stats.max_health
	character.visible = true
	character.controllable = true
	state_machine.transition_to("Idle")
