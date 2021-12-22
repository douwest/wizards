extends Node2D


onready var light_particles: Particles2D = $LightParticles

func _ready():
	light_particles.emitting = true


func _physics_process(delta) -> void:
	if light_particles.emitting:
		return
	else:
		self.queue_free()
