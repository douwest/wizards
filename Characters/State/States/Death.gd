extends CharacterState

onready var particles = $Particles2D

# Upon entering the state, we set the Player node's velocity to zero.
func enter(_msg := {}) -> void:
	# We must declare all the properties we access through `owner` in the `Player.gd` script.
	character.velocity = Vector2.ZERO
	character.visible = false
	particles.emitting = true

