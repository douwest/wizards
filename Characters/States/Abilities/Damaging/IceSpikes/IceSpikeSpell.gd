extends Spell

export (float) var impact_force = 1250.0

func _ready():
	$AnimationPlayer.play("emerge")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "emerge":
		self.queue_free()


func _on_IceSpikeSpell_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage(damage, body.position, Vector3.UP, impact_force)
