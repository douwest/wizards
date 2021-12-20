extends State

var body = null

func enter(msg := {}) -> void:
	if msg.body:
		body = msg.body

func physics_update(_delta: float) -> void:
	var direction = self.position.direction_to(body.position)
	
