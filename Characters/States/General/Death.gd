extends CharacterState

onready var particles = $DeathParticles

# Upon entering the state, we set the Player node's velocity to zero.
func enter(msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	character.velocity = Vector2.ZERO
	character.visible = false
	if msg.direction:
		particles.process_material.direction = msg.direction
	if msg.hit_position:
		particles.position = msg.hit_position
	particles.emitting = true
