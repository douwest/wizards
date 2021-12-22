extends Actor


export var health = 10
onready var state_machine: StateMachine = $StateMachine

onready var detection_zone: Area2D = $PlayerDetectionZone

func take_damage(damage, pos, dir):
	health -= damage
	if health <= 0:
		state_machine.transition_to("Death", {direction = dir, hit_position = pos})
