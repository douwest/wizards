extends AbilityState

onready var origin: Position2D = $Origin
onready var vertical_ray: RayCast2D = $Origin/VerticalRaycast
onready var horizontal_ray: RayCast2D = $Origin/HorizontalRaycast
onready var particle_factory: ParticleFactory = $ParticleFactory

const max_teleport_distance := Vector2(172, 240)
const step_size = 12

func enter(_msg := {}) -> void:
	reset_rays()
	
	origin.global_position = character.global_position # important! sets origin of teleport
	
	character.animation_tree.active = false
	character.animation_player.play_backwards('special_a')
	yield(character.animation_player, 'animation_finished')
	emit_particles(Vector2(character.position.x, character.position.y - 20))
	character.visible = false
	
	find_target_position()
	
	character.animation_player.play('special_a')
	character.visible = true
	yield(character.animation_player, 'animation_finished')
	
	character.animation_tree.active = true
	if not character.is_on_floor():
		character.state_machine.transition_to("Air")
	else:
		character.state_machine.transition_to("Idle")


func find_target_position() -> void:
	var direction = character.facing_direction.x	
	for x in range (0, max_teleport_distance.x / step_size):
		var x_offset = x * step_size
		horizontal_ray.set_cast_to(Vector2(direction * (max_teleport_distance.x - x_offset), 0))
		if horizontal_ray.is_colliding():
			for y in range (0, max_teleport_distance.y / step_size):
				var y_offset = y * step_size
				vertical_ray.position = Vector2(horizontal_ray.cast_to.x, vertical_ray.position.y)
				vertical_ray.set_cast_to(Vector2(0, max_teleport_distance.y - y_offset))
				if not vertical_ray.is_colliding():
					teleport_to(Vector2(
						horizontal_ray.position.x + horizontal_ray.cast_to.x, 
						vertical_ray.position.y + vertical_ray.cast_to.y
					))
					return
				yield(get_tree().create_timer(.005), "timeout")
		else:			
			teleport_to(Vector2(
				horizontal_ray.position.x + horizontal_ray.cast_to.x, 
				vertical_ray.position.y + vertical_ray.cast_to.y
				))
			return
		
		# For debugging/visualization:
		yield(get_tree().create_timer(.005), "timeout")

func reset_rays() -> void:
	var direction = character.facing_direction.x		
	horizontal_ray.set_cast_to(Vector2(direction * max_teleport_distance.x, 0))
	vertical_ray.set_cast_to(Vector2(0, max_teleport_distance.y))


func physics_update(_delta: float) -> void:
	character.velocity = character.move_and_slide(Vector2(0, character.velocity.y), character.FLOOR_NORMAL)


func teleport_to(rel_pos: Vector2) -> void:
	emit_particles(Vector2(character.position.x + rel_pos.x, character.position.y + rel_pos.y - 20))	
	character.position += rel_pos


func emit_particles(pos: Vector2) -> void:
	particle_factory.create_new(pos)
	
