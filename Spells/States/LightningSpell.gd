extends AbilityState

export var cooldown_time: float = 1.0 #In seconds, should be part of the new spell state

var is_on_cooldown = false

onready var spell: Node2D = $Spell # Should be part of the new spell state
onready var timer: Timer = $Timer # Should be part of the new spell state

onready var animation_player: AnimationPlayer = $Spell/AnimationPlayer # is not necessary for all spells

# should be implemented by parent as is
func enter(msg := {}) -> void:
	if is_on_cooldown:
		state_machine.transition_to("Idle")
		return
		
	determine_casting_position()
	cast_spell()


# Should be virtual method in parent class
func cast_spell():
	character.animation_tree.set('parameters/cast/blend_position', character.get_posture())	
	spell.visible = true
	animation_player.play('lightning')
	character.animation_state.travel('cast')
	timer.start(cooldown_time)
	is_on_cooldown = true


# Should be virtual method in parent class
func determine_casting_position() -> void:
	spell.rotation_degrees = 180 if character.facing_direction == -1 else 0
	spell.position = character.cast_position.position


# Signals
#Specific to this class - do not make in parent class
func _on_AnimationPlayer_animation_finished(anim_name):
	spell.visible = false
	state_machine.transition_to('Idle')


# Should be handled in code instead of scene obj and be implemented by parent class
func _on_Timer_timeout():
	is_on_cooldown = false
