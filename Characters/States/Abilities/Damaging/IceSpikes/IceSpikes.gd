extends SpellState

export var number_spikes: int = 5
export var delay: float = 0.4
export var max_distance = 240

onready var spell_factory = $SpellFactory

var spike_positions := []



func cast_spell() -> void:
	character.animation_tree.set('parameters/cast/blend_position', character.Posture.HIGH)
	character.animation_state.travel('cast')
	for i in number_spikes:
		spike_positions.append(get_offset())
	yield(get_tree().create_timer(delay), "timeout")
	for spike_position in spike_positions:
		spell_factory.create_new(spike_position)
	character.state_machine.transition_to("Idle")


func get_offset() -> Vector2:
	# Get any uniformly distributed number between - 120 and 120
	var offset = -(max_distance / 2) + (randi() % max_distance)
	
	# Try as long as it is between -32 , 32 (too close to character)
	while offset >= -32 and offset <= 32:
		offset = -(max_distance / 2) + (randi() % max_distance)
	return Vector2(character.position.x + offset, character.position.y)


func exit() -> void:
	spike_positions.clear()
