extends SpellState


onready var spell: Node2D = $Spell 
onready var animation_player: AnimationPlayer = $Spell/AnimationPlayer 

func cast_spell():
	character.animation_tree.set('parameters/cast/blend_position', character.get_posture())	
	character.animation_state.travel('cast')
	
	animation_player.play('lightning')

func determine_casting_position() -> void:
	spell.rotation_degrees = 180 if character.facing_direction == -1 else 0
	spell.position = character.cast_position.position


# Signals specific to this spell
func _on_AnimationPlayer_animation_finished(anim_name):
	state_machine.transition_to('Idle')
