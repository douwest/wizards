extends Node2D


onready var dust_particles: Particles2D = $DustParticles

func _ready():
	dust_particles.emitting = true
	
func _physics_process(delta) -> void:
	if dust_particles.emitting:
		return
	else:
		self.queue_free()
