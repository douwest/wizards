extends Node2D
class_name ParticleFactory


var particles := []
export (PackedScene) var particle_scene = null
export var buffer_size = 96

func create_new(pos: Vector2) -> void:
	var new_particles = particle_scene.instance()
	new_particles.global_position = pos
	particles.append(new_particles)
	add_child(new_particles)
	new_particles.emitting = true
	
func _physics_process(delta):
	if particles.size() > buffer_size:
		remove_child(particles.front())
		particles.erase(particles.front())
