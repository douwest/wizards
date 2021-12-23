extends AbilityState
class_name SpellState

export var cooldown_time: float = 1.0 #In seconds
var is_on_cooldown = false
var timer: Timer = Timer.new() 

func _ready():
	var _err = timer.connect('timeout', self, 'reset_cooldown')
	add_child(timer)


func enter(_msg := {}) -> void:
	if is_on_cooldown:
		state_machine.transition_to("Idle")
		return
			
	determine_casting_position()
	cast_spell()
	start_cooldown()


func start_cooldown():
	is_on_cooldown = true
	timer.start(cooldown_time)


func reset_cooldown():
	is_on_cooldown = false


#Virtual function. Should be implemented by parent
func cast_spell():
	pass


#Virtual function. Should be implemented by parent
func determine_casting_position():
	pass

