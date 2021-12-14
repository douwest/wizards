class_name CastPosition
extends Position2D

const HORIZONTAL_CAST_OFFSET = 28.0
var character

func _ready() -> void:
	yield(owner, "ready")
	character = owner
	assert(character != null)
	
func _physics_process(_delta: float):
	position.x = character.position.x + (character.facing_direction * HORIZONTAL_CAST_OFFSET)
	position.y = character.position.y + get_cast_height()
	
func get_cast_height() -> int:
	match character.get_posture():
		character.Posture.LOW: return -8
		character.Posture.MEDIUM: return -24
		character.Posture.HIGH: return -40
		_: return -1

