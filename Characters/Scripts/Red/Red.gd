extends Character


const TELEPORT_DISTANCE = 150
const MARGIN = 32

var Lightning = preload("res://Spells/Scenes/AnimatedSpell.tscn")

func _physics_process(_delta):
	if Input.is_action_just_released("move_3"):
		controllable = false
		animationPlayer.play("teleport")


func teleport():
	var space_state = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	if Input.is_action_pressed("extend"):
		#Teleport up
		global_position.y -= TELEPORT_DISTANCE		
	elif Input.is_action_pressed("crouch"):
		#Teleport down
		var result = space_state.intersect_ray(global_position, Vector2(position.x, position.y + TELEPORT_DISTANCE), [self])	
		if result:
			global_position.y = result.values()[0][1]
		else:
			global_position.y += TELEPORT_DISTANCE 
	else:
		#Teleport horizontally in player direction
		var h_direction = sprite.scale.x
		var result = space_state.intersect_ray(Vector2(global_position.x, global_position.y - MARGIN), Vector2(position.x + h_direction * TELEPORT_DISTANCE, position.y), [self])		
		if result:
			global_position.x = result.values()[0][0] - (MARGIN * h_direction)
		else:
			global_position.x += h_direction * TELEPORT_DISTANCE


func cast_spell():
	var spell = Lightning.instance()
	get_parent().add_child(spell)
	spell.global_transform = castPosition.global_transform
	spell.start(sprite.scale.x)

