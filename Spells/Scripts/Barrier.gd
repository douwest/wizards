extends Area2D


onready var sprite = $Sprite
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get('parameters/playback')
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var spell_light: Light2D = $SpellLight

remotesync func disable():
	visible = false
	collision_shape.disabled = true
	spell_light.energy = 0
	
func enable():
	spell_light.energy = 1
	animation_tree.active = true
	animation_state.travel("start_cast")
	collision_shape.disabled = false
	
