extends StaticBody2D
class_name Level

export var limit_left: int = -1000000
export var limit_right: int = 1000000
export var limit_top: int = -1000000
export var limit_bottom: int = 1000000

onready var spawn_points: Node2D = $SpawnPoints

func get_random_spawn_point() -> Vector2:
	var points = spawn_points.get_children()
	return points[randi() % points.size()].global_position
