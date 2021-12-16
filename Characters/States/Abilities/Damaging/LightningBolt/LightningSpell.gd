extends SpellState


onready var spell: Node2D = $Spell 
onready var animation_player: AnimationPlayer = $Spell/AnimationPlayer 
onready var cast_timer: Timer = $Spell/CastTimer

var is_ready = false
var cast_time = 0.5

func update(_delta: float) -> void:
	if not Input.is_action_pressed("attack"):
		cast_timer.stop()
		$Particles2D.visible = false
		if is_ready:
			character.animation_state.travel("recoil")
			animation_player.play('lightning')
		else:
			state_machine.transition_to('Idle')
	else:
		if is_ready:
			$Particles2D.process_material.radial_accel = -100
		else:
			$Particles2D.process_material.radial_accel -= 10

func cast_spell():
	$Particles2D.process_material.radial_accel = 100
	is_ready = false
	character.animation_tree.set('parameters/cast/blend_position', character.get_posture())
	character.animation_state.travel('cast')
	cast_timer.start(cast_time)
	$Particles2D.visible = true


func determine_casting_position() -> void:
	spell.rotation_degrees = 180 if character.facing_direction == -1 else 0
	spell.position = character.cast_position.position
	$Particles2D.position = character.cast_position.position


func _on_CastTimer_timeout():
	is_ready = true
