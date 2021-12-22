extends Area2D
class_name Spell


export var damage = 10
export var stun_duration = 1.0

func _on_Spell_body_entered(body):
	if body.has_method('stun'):
		body.stun(stun_duration)

