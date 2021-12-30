extends Actor
class_name Character

signal died(pinfo, lives)

const FLOOR_DETECT_DISTANCE = 20.0

export var acceleration: float = 0.5
export var friction: float = 0.275

export (PackedScene) var attack_state = null
export (PackedScene) var special_a_state = null
export (PackedScene) var special_b_state = null

var attack_state_name = 'undefined'
var special_a_state_name = 'undefined'
var special_b_state_name = 'undefined'

onready var sprite: Sprite = $Sprite
onready var tween: Tween = $Tween
onready var stats: Stats = $Stats
onready var camera: PlayerCamera = $PlayerCamera
onready var animation_state = $AnimationTree.get('parameters/playback')
onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_player: AnimationPlayer = $AnimationTree/AnimationPlayer
onready var state_machine: StateMachine = $StateMachine
onready var cast_position: CastPosition = $CastPosition
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var invincibility_timer: Timer = $Effects/InvincibilityTimer
onready var effects_animation_player: AnimationPlayer = $Effects/AnimationPlayer

enum Posture { 
	LOW = 0, 
	MEDIUM = 1, 
	HIGH = 2 
}

var posture = Posture.MEDIUM
var facing_direction := Vector2.RIGHT
var tick_count := 0
var delta_elapsed: float = 0.0


# Lifecycle hooks

func _ready() -> void:
	initialize_custom_states()
	rpc('set_camera')


func _physics_process(_delta: float) -> void:
	tick_count += 1
	delta_elapsed += _delta
	update_sprite_directions(get_direction().x)
	# Update at 20 hz
	if is_network_master() && tick_count % 3 == 0:
		rpc_unreliable("update_puppet", global_position, facing_direction, get_posture(),  delta_elapsed, state_machine.state.name, state_machine.message)
		delta_elapsed = 0


# Movement and general logic

func get_posture() -> int:
	if is_network_master():
		if Input.is_action_just_pressed("crouch") or Input.is_action_pressed("crouch"):
			return Posture.LOW
		if Input.is_action_just_pressed("extend") or  Input.is_action_pressed("extend"):
			return Posture.HIGH
		return Posture.MEDIUM
	return posture
	
	
func update_sprite_directions(horizontal_direction):
	if horizontal_direction == 0 || state_machine.state.name == "Death":
		return
	facing_direction = Vector2(horizontal_direction, facing_direction.y)
	sprite.scale.x = facing_direction.x


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


func is_stopped():
	return velocity.x >= -10 and velocity.x <= 10


func get_direction() -> Vector2:
	if is_network_master():
		return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
		)
	return facing_direction


# Combat

func take_damage(damage: int, _position: Vector2, _direction: Vector3, impact_speed = null) -> void:
	if is_invincible():
		return
	
	knockback(_direction.x, impact_speed)
	camera.screen_shake.start(0.20, 24, 20, 2)
	stats.set_current_health(stats.current_health - damage)
	
	if is_network_master() and stats.current_health <= 0:
		state_machine.transition_to("Death", {direction = _direction, hit_position = _position})
		emit_signal('died', Gamestate.player_info, stats.lives)


func stun(_duration: float) -> void:
	if is_invincible():
		return
	
	camera.screen_shake.start(0.15, 10, 16, 1)
	
	if is_network_master():
		state_machine.transition_to("Stunned", {duration = _duration})


func knockback(h_direction: float, impact_speed: float):
	if is_network_master() and impact_speed:
		velocity = move_and_slide(Vector2(-h_direction * (impact_speed * 3), 0), FLOOR_NORMAL)


# Custom states

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


func _on_InvincibilityTimer_timeout() -> void:
	effects_animation_player.stop()


func is_invincible() -> bool:
	return not invincibility_timer.is_stopped()


# Network synchronization

puppet func update_puppet(_position: Vector2, _direction: Vector2, _posture: int, delta: float, _state_name: String, _state_msg := {}) -> void:
	var _err = tween.interpolate_property(self, 'global_position', global_position, _position, delta)
	_err = tween.start()
	facing_direction = _direction
	posture = _posture
	if _state_name and _state_name != state_machine.state.name:
		state_machine.transition_to(_state_name, _state_msg)


master func set_camera() -> void:
	camera.make_current()


