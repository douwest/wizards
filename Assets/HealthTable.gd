extends StaticBody2D


var lives = 5

onready var animation_tree = $AnimationPlayer/AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_lives(value: int) -> void:
	lives = value
	animation_tree["parameters/playback"].travel('full_to_80')
