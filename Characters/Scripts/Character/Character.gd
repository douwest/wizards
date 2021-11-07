class_name Character
extends Actor

var Spell = preload("res://Spells/Spell.tscn")
var Barrier = preload("res://Spells/Barrier.tscn")

const FLOOR_DETECT_DISTANCE = 20.0

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var castPosition = $CastPosition
onready var castLight = $CastPosition/CastLight
onready var barrier = $Barrier
onready var tween = $Tween

var camera = null

enum State { IDLE, JUMP, RUN, CAST, DIE, BLOCK }
enum Posture { LOW, MEDIUM, HIGH }

var run_speed = 310
var jump_strength = 500
var state = State.IDLE
var posture = Posture.MEDIUM

var acceleration = 0.25
var friction = 0.25

puppet var puppet_position = Vector2(0,0) setget set_puppet_position
puppet var puppet_velocity = Vector2(0,0)
puppet var puppet_direction = 1
puppet var puppet_state = State.IDLE
puppet var puppet_posture = Posture.MEDIUM

func _ready():
	sprite.modulate = Color(randf(), randf(), randf(), 1)
	speed = Vector2(run_speed, jump_strength)
	if is_network_master():
		camera = Camera2D.new()
		camera.zoom = Vector2(0.5, 0.5)		
		self.add_child(camera)
		camera.make_current()


func _physics_process(_delta):
	if(is_network_master()):
		
		state = get_state()
		posture = get_posture()
		
		var direction = get_direction()
		
		var is_block_interrupted = Input.is_action_just_released("move_2")
		var is_cast_interrupted = Input.is_action_just_released("move_1")
		
		if(is_block_interrupted):
			remove_barrier()
		if(is_cast_interrupted):
			castLight.energy = 0
			
		var is_jump_interrupted = Input.is_action_just_released("jump") and _velocity.y < 0.0
		_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)

		var snap_vector = Vector2.ZERO
		if direction.y == 0.0:
			snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
			
		_velocity = move_and_slide_with_snap(_velocity, snap_vector, FLOOR_NORMAL, false, 4, 0.9, false)

		if direction.x != 0:
			if direction.x > 0:
				sprite.scale.x = 1
				barrier.set_sprite_scale_x(1)
				castPosition.position.x = 28
			else:
				sprite.scale.x = -1
				barrier.set_sprite_scale_x(-1)
				castPosition.position.x = -28
		if state == State.BLOCK:
			animationPlayer.play("block_" + get_posture_suffix(posture))
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
		update_casting_position()
		update_barrier_position()
	else:
		if puppet_velocity.x != 0:
			if puppet_velocity.x > 0:
				sprite.scale.x = 1
				barrier.set_sprite_scale_x(1)
				castPosition.position.x = 28
			else:
				sprite.scale.x = -1
				barrier.set_sprite_scale_x(-1)	
				castPosition.position.x = -28			
		if not tween.is_active():
			puppet_velocity = move_and_slide(puppet_velocity * speed)
			
		if puppet_state == State.BLOCK:
			animationPlayer.play("block_" + get_posture_suffix(puppet_posture))
		else:
			remove_barrier()
		if puppet_state == State.CAST:
			animationPlayer.play("attack_" + get_posture_suffix(puppet_posture))
		elif puppet_state == State.RUN:
			animationPlayer.play("walk")
		elif puppet_state == State.JUMP and puppet_velocity.y > 0:
			animationPlayer.play("falling")
		elif puppet_state == State.JUMP and puppet_velocity.y < 0:
			animationPlayer.play("jump")
		elif puppet_state == State.IDLE:
			animationPlayer.play("idle_" + get_posture_suffix(puppet_posture))
		update_casting_position_from_puppet()
		update_barrier_position()


func get_posture() -> int:
	if Input.is_action_pressed("crouch"):
		return Posture.LOW
	elif Input.is_action_pressed("extend"):
		return Posture.HIGH
	else:
		return Posture.MEDIUM


func get_state() -> int:
	if Input.is_action_pressed("move_1"):
		return State.CAST
	elif Input.is_action_pressed("move_2"):
		return State.BLOCK
	elif !is_on_floor():
		return State.JUMP
	elif Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		return State.RUN
	else:
		return State.IDLE


func get_cast_height(posture) -> int:
	if posture == Posture.LOW:
		return -8
	elif posture == Posture.MEDIUM:
		return -24
	else:
		return -40


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1 if is_on_floor() and Input.is_action_just_pressed("jump") else 0
	)

func get_posture_suffix(posture) -> String:
	if posture == Posture.HIGH:
		return 'high'
	elif posture == Posture.MEDIUM:
		return 'mid'
	else:
		return 'low'


func calculate_move_velocity(linear_velocity, direction, speed, is_jump_interrupted) -> Vector2:
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


func get_sprite_direction() -> int:
	if sprite.scale.x < 0:
		return -1
	else:
		return 1


func cast_spell() -> void:
	var spell = Spell.instance()
	spell.set_speed_from_direction(get_sprite_direction())
	get_parent().add_child(spell)
	spell.global_transform = castPosition.global_transform


func update_barrier_position() -> void:
	barrier.global_transform = castPosition.global_transform
	

func update_casting_position() -> void:
	castPosition.position.y = get_cast_height(posture)


func update_casting_position_from_puppet() -> void:
	castPosition.position.y = get_cast_height(puppet_posture)


func cast_barrier():
	barrier.visible = true


func remove_barrier():
	barrier.visible = false


func _on_NetworkTickRate_timeout():
	if is_network_master():
		rset_unreliable('puppet_position', global_position)
		rset_unreliable('puppet_velocity', _velocity)
		rset_unreliable('puppet_state', state)
		rset_unreliable('puppet_posture', posture)
	
	
func set_puppet_position(new_value) -> void:
	puppet_position = new_value
	tween.interpolate_property(self, 'global_position', global_position, puppet_position, 0.1)
	tween.start()
