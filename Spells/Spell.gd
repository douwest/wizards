extends Area2D

export var BULLET_SPEED = 400
var speed = 0

func _physics_process(delta):
	position += transform.x * speed * delta

func set_speed_from_direction(direction: int):
	if direction == 1:
		speed = BULLET_SPEED
	else: 
		speed = -BULLET_SPEED

func _on_Spell_body_entered(body):
	queue_free()
