extends Actor
class_name Character

signal died(pinfo, lives)

const FLOOR_DETECT_DISTANCE = 20.0

export var acceleration: float = 0.5
export var friction: float = 0.25

export (PackedScene) var attack_state = null
export (PackedScene) var special_a_state = null
export (PackedScene) var special_b_state = null

var attack_state_name = 'undefined'
var special_a_state_name = 'undefined'
var special_b_state_name = 'undefined'

onready var sprite: Sprite = $Sprite
onready var tween: Tween = $Tween
onready var stats: Stats = $Stats
onready var camera: Camera2D = $Camera2D
onready var animation_state = $AnimationTree.get('parameters/playback')
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_player: AnimationPlayer = $AnimationTree/AnimationPlayer
onready var state_machine: StateMachine = $StateMachine
onready var cast_position: CastPosition = $CastPosition

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

var posture = Posture.MEDIUM
var facing_direction = 1
var controllable = true


#puppet var puppet_position = Vector2(0,0) setget set_puppet_position
#puppet var puppet_velocity = Vector2(0,0)
#puppet var puppet_state = State.IDLE
#puppet var puppet_posture = Posture.MEDIUM
#puppet var puppet_health = 9999
#puppet var puppet_lives = 9999
#puppet var puppet_visible = true


func _ready() -> void:
	initialize_custom_states()
	if is_network_master():
		camera.make_current()


func _physics_process(_delta) -> void:
	update_sprite_directions(get_direction().x)


func get_posture() -> int:
	if Input.is_action_pressed("crouch"):
		return Posture.LOW
	if Input.is_action_pressed("extend"):
		return Posture.HIGH
	return Posture.MEDIUM


func update_sprite_directions(horizontal_direction):
	if horizontal_direction == 0:
		return
	facing_direction = horizontal_direction
	sprite.scale.x = facing_direction


func calculate_snap_vector(vertical_direction) -> Vector2:
	var snap_vector = Vector2.ZERO
	if vertical_direction == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	return snap_vector


func calculate_move_velocity(linear_velocity, direction, speed, is_jump_interrupted) -> Vector2:
	var v = linear_velocity
	
	if direction.x != 0:
		v.x = lerp(v.x, speed.x * direction.x, acceleration)
	else:
		v.x = lerp(v.x, 0.0, friction)
		
	if direction.y != 0.0:
		v.y = speed.y * direction.y
	if is_jump_interrupted:
		v.y *= 0.6
	return v


func take_damage(damage: int, pos: Vector2, dir: Vector3) -> void:
	stats.set_current_health(stats.current_health - damage)
	if stats.current_health <= 0:
		state_machine.transition_to("Death", {direction = dir, hit_position = pos})


func player_died() -> void:
	if(is_network_master()):
		emit_signal('died', Gamestate.player_info, 99)
		controllable = false
		if stats.lives > 0:
			global_position = Vector2(0, 0)


func respawn() -> void:
	if(is_network_master()):
		posture = Posture.MEDIUM
		stats.current_health = stats.max_health
		stats.lives -= 1
	visible = true
	controllable = true


func set_controllable(value) -> void:
	controllable = value


func is_stopped():
	return velocity.x >= -10 and velocity.x <= 10


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)


func initialize_custom_states():
	if attack_state:
		var state = attack_state.instance()
		attack_state_name = state.name
		state_machine.add_child(state)
		state.init(self, state_machine)
	if special_a_state:
		var state = special_a_state.instance()
		special_a_state_name = state.name
		state_machine.add_child(state)
		state.init(self, state_machine)
	if special_b_state:
		var state = special_b_state.instance()
		special_b_state_name = state.name
		state_machine.add_child(state)
		state.init(self, state_machine)
#func set_puppet_position(new_value) -> void:
#	puppet_position = new_value
#	var _err = tween.interpolate_property(self, 'global_position', global_position, puppet_position, 0.1)
#	_err = tween.start()
#	if _err:
#		print(_err)

