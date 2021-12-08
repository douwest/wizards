extends Area2D



onready var sprite = $Sprite
onready var animation_player = $Sprite/AnimationPlayer
onready var animation_tree = $Sprite/AnimationTree

func set_sprite_scale_x(scale: float):
	if sprite:
		sprite.scale.x = scale

func disable():
	visible = false
	$CollisionShape2D.disabled = true
	
func enable():
	visible = true
	$CollisionShape2D.disabled = false
	animation_player.play("start cast")
	
