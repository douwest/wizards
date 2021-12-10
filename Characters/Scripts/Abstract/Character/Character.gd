class_name Character
extends Actor

signal died(pinfo, lives)

var Spell = preload("res://Spells/Scenes/Spell.tscn")

var barrier_cooldown_active = false

const HORIZONTAL_CAST_OFFSET = 28.0
const FLOOR_DETECT_DISTANCE = 20.0

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var castPosition = $CastPosition
onready var castLight = $CastPosition/CastLight
onready var tween = $Tween
onready var stats = $Stats
onready var respawnTimer = $Timers/RespawnTimer
onready var barrierCooldownTimer = $Timers/BarrierCooldownTimer
onready var camera = $Camera2D

onready var animation_state = $AnimationTree.get('parameters/playback')
onready var idle_blend_position = $AnimationTree.get('parameters/idle/blend_position')
onready var run_blend_position = $AnimationTree.get('parameters/run/blend_position')

enum State { 
	IDLE = 0, 
	JUMP = 1, 
	RUN = 2, 
	CAST = 3, 
	DEATH = 4, 
	BLOCK = 5, 
	READY_TO_ATTACK = 6, 
	ATTACK = 7 
	}
	
enum Posture { 
	LOW = 0, 
	MEDIUM = 1, 
	HIGH = 2 
}

export var run_speed = 200
export var jump_strength = 525
#var state = State.IDLE
var posture = Posture.MEDIUM
var facing_direction = 1
var controllable = true

var acceleration = 0.5
var friction = 0.25

puppet var puppet_position = Vector2(0,0) setget set_puppet_position
puppet var puppet_velocity = Vector2(0,0)
puppet var puppet_state = State.IDLE
puppet var puppet_posture = Posture.MEDIUM
puppet var puppet_health = 9999
puppet var puppet_lives = 9999
puppet var puppet_visible = true


func _ready() -> void:
	speed = Vector2(run_speed, jump_strength)
	respawnTimer.connect('timeout', self, 'respawn')
	if is_network_master():
		camera.make_current()


func _physics_process(_delta) -> void:
	posture = get_posture()
	idle_blend_position = posture
	run_blend_position = posture
	print(idle_blend_position, ', ', run_blend_position)
	update_casting_position()
	update_sprite_directions(get_direction().x)
#	if !controllable:
#		return
#	if is_network_master():
#		respawnTimer.stop()
#		if state != State.BLOCK:
#			posture = get_posture()
#			state = get_state()		
#			var direction = get_direction()
#
#			if state != State.BLOCK:
#				remove_barrier()
#			if state != State.CAST:
#				castLight.energy = 0
#
#			if !(state == State.CAST || state == State.BLOCK) :
#				var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
#				_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
#				var snap_vector = calculate_snap_vector(direction.y)
#				_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false)
#
#			update_sprite_directions(direction.x)
#			play_animation(state, posture, _velocity)
#			update_casting_position(posture)
#	else:
#		visible = puppet_visible
#		if not tween.is_active():
#			puppet_velocity = move_and_slide(puppet_velocity * speed)
#		if puppet_state != State.BLOCK:
#			remove_barrier()
#		if puppet_state != State.CAST:
#			castLight.energy = 0
#		update_sprite_directions(puppet_velocity.x)
#		play_animation(puppet_state, puppet_posture, puppet_velocity)
#		update_casting_position(puppet_posture)
#	update_barrier_position()


func get_posture() -> int:
	if Input.is_action_pressed("crouch"):
		return Posture.LOW
	elif Input.is_action_pressed("extend"):
		return Posture.HIGH
	else:
		return Posture.MEDIUM


#func get_state() -> int:
#	if(stats.current_health <= 0):
#		return State.DEATH
#
#	if Input.is_action_just_released("move_1") and state == State.READY_TO_ATTACK and is_on_floor():
#		return State.ATTACK
#	elif Input.is_action_pressed("move_1") and state == State.READY_TO_ATTACK and is_on_floor():
#		return State.READY_TO_ATTACK
#
#
#	if Input.is_action_pressed("move_1") and state != State.READY_TO_ATTACK and is_on_floor():
#		return State.CAST
#	elif !barrier_cooldown_active and Input.is_action_pressed("move_2") and is_on_floor():
#		barrier_cooldown_active = true
#		barrierCooldownTimer.start()
#		return State.BLOCK
#	elif !is_on_floor():
#		return State.JUMP
#	elif Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
#		return State.RUN
#	else:
#		return State.IDLE


func update_sprite_directions(horizontal_direction):
	if horizontal_direction == 0:
		return
	facing_direction = horizontal_direction
	sprite.scale.x = facing_direction
	castPosition.position.x = facing_direction * HORIZONTAL_CAST_OFFSET


func get_cast_height() -> int:
	match posture:
		Posture.LOW: return -8
		Posture.MEDIUM: return -24
		Posture.HIGH: return -40
		_: return -1


func get_posture_suffix() -> String:
	match posture:
		Posture.LOW: return 'low'
		Posture.MEDIUM: return 'mid'
		Posture.HIGH: return 'high'
		_: return 'error - posture not matched'


func calculate_snap_vector(vertical_direction) -> Vector2:
	var snap_vector = Vector2.ZERO
	if vertical_direction == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	return snap_vector


func calculate_move_velocity(linear_velocity, direction, speed, is_jump_interrupted) -> Vector2:
	var v = linear_velocity
	
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		v.x = lerp(v.x, speed.x * direction.x, acceleration)
	else:
		v.x = lerp(v.x, 0.0, friction)
		
	if direction.y != 0.0:
		v.y = speed.y * direction.y
	if is_jump_interrupted:
		v.y *= 0.6
	return v
	

func cast_spell() -> void:
	var spell = Spell.instance()
	spell.set_speed_from_direction(get_direction().x)
	get_parent().add_child(spell)
	spell.global_transform = castPosition.global_transform


func update_casting_position() -> void:
	castPosition.position.y = get_cast_height()


func _on_NetworkTickRate_timeout() -> void :
	if is_network_master():
		rset_unreliable('puppet_position', global_position)
		rset_unreliable('puppet_velocity', velocity)
#		rset_unreliable('puppet_state', state)
		rset_unreliable('puppet_posture', posture)
		rset_unreliable('puppet_health', stats.current_health)
		rset_unreliable('puppet_lives', stats.lives)
		rset_unreliable('puppet_visible', visible)
		

func set_puppet_position(new_value) -> void:
	puppet_position = new_value
	tween.interpolate_property(self, 'global_position', global_position, puppet_position, 0.1)
	tween.start()


func take_damage(damage) -> void:
	stats.set_current_health(stats.current_health - damage)


func player_died() -> void:
	if(is_network_master()):
		emit_signal('died', Gamestate.player_info, 99)
		controllable = false
		if stats.lives > 0:
			global_position = Vector2(0, 0)
			respawnTimer.start()


func respawn() -> void:
	if(is_network_master()):
#		state = State.IDLE
		posture = Posture.MEDIUM
		stats.current_health = stats.max_health
		stats.lives -= 1
	visible = true
	controllable = true


func set_controllable(value) -> void:
	controllable = value


func is_stopped():
	return velocity.x >= -10 and velocity.x <= 10


func _on_BarrierCooldownTimer_timeout():
	barrier_cooldown_active = false


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)
