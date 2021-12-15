extends Area2D
class_name Spell


export var damage = 10


func _on_Spell_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage(damage)
