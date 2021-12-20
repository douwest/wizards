extends State

func enter(msg := {}):
	owner.detection_zone.connect('body_entered', self, 'on_body_entered')


func on_body_entered(body) -> void:
	state_machine.transition_to("Chasing", {node = body})
