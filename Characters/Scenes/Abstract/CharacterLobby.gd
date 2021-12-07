extends Control

onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_player_two: bool = false setget set_is_player_two


func _ready():
	animation_player.play('idle')
	

func ready_up():
	animation_player.play('ready')


func unready():
	animation_player.play('unready')


func set_is_player_two(value):
	is_player_two = value
	if is_player_two:
		$Sprite.scale.x = -1 * $Sprite.scale.x


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'unready' or anim_name == 'intro':
		animation_player.play('idle')
