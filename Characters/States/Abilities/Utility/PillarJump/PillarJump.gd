extends AbilityState

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer

export var Pillar_Strength = 1500
export var Pillar_Speed = 550

var count = 0


func enter(_msg := {}) -> void:
	count = 0
	character.friction = 0.0
	animation_player.play('extend')
	sprite.scale.x = character.facing_direction.x
	self.position = character.position


func physics_update(_delta: float) -> void:
	if count >= 10:
		state_machine.transition_to("Air")
		return
	if count < 5:
		character.velocity.y = -Pillar_Strength
	else:
		character.velocity.x = character.facing_direction.x * Pillar_Speed

	character.velocity = character.calculate_move_velocity(character.velocity, Vector2(character.facing_direction.x, -1), character.speed, false)
	character.velocity = character.move_and_slide(character.velocity, character.FLOOR_NORMAL)

	count += 1


func exit() -> void:
	character.friction = 0.25
