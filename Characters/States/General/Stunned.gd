# Stunned.gd
extends CharacterState

onready var stun_timer: Timer = $StunTimer
onready var daze_particles: Particles2D = $DazedParticles

export var default_stun_duration = 1.0 # In seconds

func enter(msg := {}) -> void:
	if msg.has("duration"):
		stun_timer.start(msg.duration)
	else:
		stun_timer.start(default_stun_duration)
	character.animation_tree.active = false
	character.effects_animation_player.play("hit")
	daze_particles.position = Vector2(character.position.x, character.position.y - 48)
	daze_particles.emitting = true

func exit() -> void:
	daze_particles.emitting = false
	stun_timer.stop() #If interrupted (for example by dying while stunned)

func _on_StunTimer_timeout():
	character.animation_tree.active = true
	state_machine.transition_to("Idle")
