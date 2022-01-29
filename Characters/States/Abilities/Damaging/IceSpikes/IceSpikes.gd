extends SpellState

export var number_spikes: int = 6
export var max_distance: int = 240

onready var spell_factory: Node2D = $SpellFactory
onready var animation_player: AnimationPlayer = $AnimationPlayer

var spike_positions := []
var buffer_size := 32


func cast_spell() -> void:
	character.animation_tree.active = false
	character.animation_player.play('special_a')
	animation_player.play("glyphs")

	for i in number_spikes:
		spike_positions.append(get_offset(i))
		
	yield(animation_player, "animation_finished")

	for spike_position in spike_positions:
		spell_factory.create_new(spike_position)

	character.animation_tree.active = true
	character.state_machine.transition_to("Idle")


func determine_casting_position():
	self.position = character.position


func get_offset(index: int) -> Vector2:
	if index > number_spikes / 2 - 1:
		index += 1
	var spacing = max_distance / number_spikes
	var offset = -(max_distance / 2) + (index * spacing)
	return Vector2(offset, 0)


func exit() -> void:
	spike_positions.clear()
