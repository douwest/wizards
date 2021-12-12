extends CharacterState

onready var sprite: Sprite = $Sprite
onready var animation_player: AnimationPlayer = $AnimationPlayer

export var Pillar_Strength = 10000
export var Pillar_Speed = 5000

var count = 0

# Virtual function. Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	count = 0
	character.friction = 0.0
	animation_player.play('extend')
	sprite.scale.x = character.facing_direction
	self.global_transform = character.global_transform	


func physics_update(_delta: float) -> void:
#	if not character.is_on_floor():
#		state_machine.transition_to("Air")
#		return
	
	if count >= 10:
		state_machine.transition_to("Air")
		return
	if count < 5:
		character.velocity.y = -Pillar_Strength
	else:
		character.velocity.x = character.facing_direction * Pillar_Speed
	
	
	character.velocity = character.calculate_move_velocity(character.velocity, Vector2(character.facing_direction, -1), character.speed, false)
	character.velocity = character.move_and_slide(character.velocity, character.FLOOR_NORMAL)
	
	count += 1


func exit() -> void:
	character.friction = 0.25
