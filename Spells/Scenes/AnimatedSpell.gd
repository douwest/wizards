extends Node2D


onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var collider = $CollisionShape2D

func start(direction: int):
	if(direction < 0):
		rotation_degrees = 180
	animationPlayer.play("cast")


func _on_AnimationPlayer_animation_finished(_anim_name):
	queue_free()
