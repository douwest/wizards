class_name Character
extends Actor

const FLOOR_DETECT_DISTANCE = 20.0

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer

enum State { IDLE, JUMP, RUN }
enum Posture { LOW, MEDIUM, HIGH }

var run_speed = 310
var jump_strength = 500
var state = State.IDLE
var posture = Posture.MEDIUM

func _ready():
	speed = Vector2(run_speed, jump_strength)


func _physics_process(_delta):
	
	state = get_state()
	posture = get_posture()
	
	print('state: ', state, " posture: ", posture)

	var direction = get_direction()
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)

	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false)
	# When the character’s direction changes, we want to to scale the Sprite accordingly to flip it.
	# This will make Robi face left or right depending on the direction you move.
	if direction.x != 0:
		if direction.x > 0:
			sprite.scale.x = 1
		else:
			sprite.scale.x = -1

	if _velocity.x != 0:
		animationPlayer.play("Walk")


func get_posture():
	if Input.is_action_pressed("crouch"):
		return Posture.LOW
	elif Input.is_action_pressed("extend"):
		return Posture.HIGH
	else:
		return Posture.MEDIUM


func get_state():
	if !is_on_floor():
		return State.JUMP
	elif Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		return State.RUN
	else:
		return State.IDLE


func get_direction():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)


func calculate_move_velocity(
		linear_velocity,
		direction,
		speed,
		is_jump_interrupted
	):
	var velocity = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		# Decrease the Y velocity by multiplying it, but don't set it to 0
		# as to not be too abrupt.
		velocity.y *= 0.6
	return velocity
