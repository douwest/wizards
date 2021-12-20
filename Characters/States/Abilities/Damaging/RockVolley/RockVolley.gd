extends SpellState

export var kinematic_spell = preload("res://Spells/Scenes/KinematicSpell.tscn")
export var cast_time: float = 0.3

onready var cast_timer: Timer = $CastTimer
var spell_instance: KinematicSpell = null


func update(_delta: float) -> void:
	if character.is_network_master() and not Input.is_action_pressed("attack"):
		rpc("interrupt")


func determine_casting_position() -> void:
	spell_instance = kinematic_spell.instance()
	spell_instance.rotation_degrees = 180 if character.facing_direction.x == -1 else 0


func cast_spell():
	character.animation_tree.set('parameters/cast/blend_position', character.get_posture())
	character.animation_state.travel('cast')
	cast_timer.start(cast_time)


func _on_CastTimer_timeout():
	cast_timer.stop()
	spell_instance.init(character.cast_position.position, character.facing_direction.x, character.get_parent())	
	state_machine.transition_to('Idle')

remotesync func interrupt() -> void:
	cast_timer.stop()
	state_machine.transition_to("Idle")
