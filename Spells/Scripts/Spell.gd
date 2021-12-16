extends Area2D
class_name Spell


export var damage = 10


func _on_Spell_body_entered(body):
	if body.has_method('take_damage'):
		var direction = body.position.direction_to(self.position)
		var hit_position = Vector2(body.position.x, self.position.y)
		body.take_damage(damage, hit_position, Vector3(direction.x, direction.y, 0))
