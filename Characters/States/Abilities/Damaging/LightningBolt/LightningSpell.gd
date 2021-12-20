extends SpellState


onready var spell: Node2D = $Spell 
onready var animation_player: AnimationPlayer = $Spell/AnimationPlayer 
onready var cast_timer: Timer = $Spell/CastTimer
onready var particles: Particles2D = $Particles2D

var is_ready = false
var cast_time = 0.5

func update(_delta: float) -> void:
	if character.is_network_master() and not Input.is_action_pressed("attack"):
		rpc("interrupt")
	else:
		if is_ready:
			particles.process_material.radial_accel = -100
		else:
			particles.process_material.radial_accel -= 10

# Should be executed locally and remotely
remotesync func interrupt() -> void:
	cast_timer.stop()
	if is_ready:
		particles.visible = false
		character.animation_state.travel("recoil")
		animation_player.play('lightning')
	else:
		state_machine.transition_to('Idle')

func cast_spell():
	particles.process_material.radial_accel = 100
	is_ready = false
	character.animation_tree.set('parameters/cast/blend_position', character.get_posture())
	character.animation_tree.set('parameters/recoil/blend_position', character.get_posture())
	character.animation_state.travel('cast')
	cast_timer.start(cast_time)
	particles.visible = true

func exit() -> void:
	spell.visible = false
	particles.visible = false

func determine_casting_position() -> void:
	spell.rotation_degrees = 180 if character.facing_direction.x == -1 else 0
	spell.position = character.cast_position.position
	particles.position = character.cast_position.position


func _on_CastTimer_timeout():
	is_ready = true
