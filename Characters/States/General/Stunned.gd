# Stunned.gd
extends CharacterState

onready var stun_timer: Timer = $StunTimer
onready var daze_particles: Particles2D = $DazedParticles

export var default_stun_duration = 1.0 # In seconds

func enter(msg := {}) -> void:
#	character.animation_tree.set('parameters/recoil/blend_position', character.get_posture())
#	character.animation_state.travel("recoil")
	if msg.has("duration"):
		stun_timer.start(msg.duration)
	else:
		stun_timer.start(default_stun_duration)
	daze_particles.position = Vector2(character.position.x, character.position.y - 48)
	daze_particles.emitting = true

func exit() -> void:
	daze_particles.emitting = false

func _on_StunTimer_timeout():
	state_machine.transition_to("Idle")
