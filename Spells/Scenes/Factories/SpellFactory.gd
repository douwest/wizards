extends Node2D
class_name SpellFactory

export (PackedScene) var spell = null

func create_new(pos) -> void:
	var new_child = spell.instance()
	new_child.global_position = pos
	add_child(new_child)
