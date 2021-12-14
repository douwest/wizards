extends Area2D


onready var sprite = $Sprite
onready var animation_state = $AnimationTree.get('parameters/playback')

func disable():
	visible = false
	$CollisionShape2D.disabled = true
	$SpellLight.energy = 0
	
func enable():
	$AnimationTree.active = true
	animation_state.travel("start_cast")
	$CollisionShape2D.disabled = false
	
