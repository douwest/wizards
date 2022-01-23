extends SpellState

export var number_spikes: int = 6
export var delay: float = 0.4
export var max_distance: int = 240

onready var spell_factory: Node2D = $SpellFactory

var spike_positions := []
var buffer_size := 32


func cast_spell() -> void:
	character.animation_tree.set('parameters/cast/blend_position', character.Posture.HIGH)
	character.animation_state.travel('cast')

	for i in number_spikes:
		spike_positions.append(get_offset(i))

	yield(get_tree().create_timer(delay), "timeout")

	for spike_position in spike_positions:
		spell_factory.create_new(spike_position)

	character.state_machine.transition_to("Idle")


func get_offset(index: int) -> Vector2:
	if index > number_spikes / 2 - 1:
		index += 1
	var spacing = max_distance / number_spikes
	var offset = -(max_distance / 2) + (index * spacing)
	return Vector2(character.position.x + offset, character.position.y)


func exit() -> void:
	spike_positions.clear()
