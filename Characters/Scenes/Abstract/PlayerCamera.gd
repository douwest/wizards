extends Camera2D
class_name PlayerCamera

onready var screen_shake : Node = $ScreenShake #To expose the screen shake to the application

func _ready() -> void:
	set_camera_limits()
	
func set_camera_limits() -> void:
	var game = owner.get_parent()
	limit_left = game.level.limit_left
	limit_right = game.level.limit_right
	limit_bottom = game.level.limit_bottom
	limit_top = game.level.limit_top
