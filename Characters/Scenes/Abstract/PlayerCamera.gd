extends Camera2D


func _ready() -> void:
	set_camera_limits()
	
func set_camera_limits() -> void:
	var game = owner.get_parent()
	limit_left = game.level.limit_left
	limit_right = game.level.limit_right
	limit_bottom = game.level.limit_bottom
	limit_top = game.level.limit_top
