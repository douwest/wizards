extends Area2D

export var bullet_speed = 400
export var damage = 10
var speed = 0


func _physics_process(delta):
	position += transform.x * speed * delta

func set_speed_from_direction(direction: int):
	if direction == 1:
		speed = bullet_speed
	else: 
		speed = -bullet_speed

func _on_Spell_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage(damage)
	queue_free()
	

func _on_Spell_area_entered(_area):
	queue_free()
