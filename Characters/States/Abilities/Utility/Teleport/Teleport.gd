extends AbilityState

const PARTICLE_OFFSET: float = 32.0

export var MAX_TELEPORT_DISTANCE: float = 150.0
export var wait_time: float = 0.25

onready var particles: Particles2D = $Particles2D
onready var timer: Timer = $Timer

func enter(_msg := {}) -> void:
	particles.emitting = true
	character.animation_state.travel('cast')
	timer.start(0.25)


func exit() -> void:
	self.position = character.position


func _on_Timer_timeout():
	particles.emitting = true
	character.position += calculate_teleport_vector()
	character.state_machine.transition_to("Air")


func calculate_teleport_vector() -> Vector2:
	var teleport_distance := Vector2(character.facing_direction.x * MAX_TELEPORT_DISTANCE, 0.0)

	while character.test_move(character.transform, teleport_distance):
		if teleport_distance.y > -(MAX_TELEPORT_DISTANCE / 2):
			teleport_distance.y -= 1
		else:
			teleport_distance.y = 0
			teleport_distance.x -= character.facing_direction.x * 5

	return teleport_distance
