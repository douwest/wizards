extends SpellState

export var kinematic_spell = preload("res://Spells/Scenes/KinematicSpell.tscn")


func cast_spell():
	character.animation_tree.set('parameters/cast/blend_position', character.get_posture())
	character.animation_state.travel('cast')


func determine_casting_position() -> void:
	var spell = kinematic_spell.instance()
	spell.rotation_degrees = 180 if character.facing_direction == -1 else 0
	spell.init(character.cast_position.position, character.facing_direction, character.get_parent())
	spell.connect('completed', self, 'on_completed')


func on_completed():
	state_machine.transition_to('Idle')
