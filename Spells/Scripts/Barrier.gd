extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var animation_tree = $Sprite/AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_sprite_scale_x(scale: float):
	if sprite:
		sprite.scale.x = scale

func disable():
	visible = false
	$CollisionShape2D.disabled = true
	
func enable():
	visible = true
	$CollisionShape2D.disabled = false
	$Sprite/AnimationPlayer.play("start cast")
	
