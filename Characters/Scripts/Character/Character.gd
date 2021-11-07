class_name Character
extends Actor

var Spell = preload("res://Spells/Spell.tscn")

const FLOOR_DETECT_DISTANCE = 20.0
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var castPosition = $CastPosition

enum State { IDLE, JUMP, RUN, CAST, DIE }
enum Posture { LOW, MEDIUM, HIGH }

var run_speed = 310
var jump_strength = 500
var state = State.IDLE
var posture = Posture.MEDIUM

var acceleration = 0.25
var friction = 0.25

func _ready():
	speed = Vector2(run_speed, jump_strength)


func _physics_process(_delta):
	
	state = get_state()
	posture = get_posture()
	castPosition.position.y = get_cast_height(posture)
	
	var direction = get_direction()
	
	var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)

	var snap_vector = Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
		
	_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false)

	if direction.x != 0:
		if direction.x > 0:
			sprite.scale.x = 1
			castPosition.position.x = 28
		else:
			sprite.scale.x = -1
			castPosition.position.x = -28

	if state == State.DIE:
		animationPlayer.play("die")
	elif state == State.CAST:
		animationPlayer.play("attack_" + get_posture_suffix(posture))
	elif state == State.RUN:
		animationPlayer.play("walk")
	elif state == State.JUMP and _velocity.y > 0:
		animationPlayer.play("falling")
	elif state == State.JUMP and _velocity.y < 0:
		animationPlayer.play("jump")
	elif state == State.IDLE:
		animationPlayer.play("idle_" + get_posture_suffix(posture))


func get_posture():
	if Input.is_action_pressed("crouch"):
		return Posture.LOW
	elif Input.is_action_pressed("extend"):
		return Posture.HIGH
	else:
		return Posture.MEDIUM


func get_state():
	if Input.is_action_pressed("move_1"):
		return State.CAST
	elif Input.is_action_pressed("move_2"):
		return State.DIE
	elif !is_on_floor():
		return State.JUMP
	elif Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		return State.RUN
	else:
		return State.IDLE


func get_cast_height(posture):
	if posture == Posture.LOW:
		return -8
	elif posture == Posture.MEDIUM:
		return -24
	else:
		return -40


func get_direction():
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)

func get_posture_suffix(posture):
	if posture == Posture.HIGH:
		return 'high'
	elif posture == Posture.MEDIUM:
		return 'mid'
	elif posture == Posture.LOW:
		return 'low'


func calculate_move_velocity(linear_velocity, direction, speed, is_jump_interrupted):
	var velocity = linear_velocity
	
	if direction.x != 0:
		velocity.x = lerp(velocity.x, speed.x * direction.x, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)
		
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y *= 0.6
	return velocity


func get_sprite_direction():
	if sprite.scale.x < 0:
		return -1
	else:
		return 1


func cast_spell():
	var spell = Spell.instance()
	spell.set_speed_from_direction(get_sprite_direction())
	owner.add_child(spell)
	spell.global_transform = castPosition.global_transform
