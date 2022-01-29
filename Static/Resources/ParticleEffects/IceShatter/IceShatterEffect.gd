extends Node2D


onready var ice_shatter_particles: Particles2D = $IceShatterParticles

func _ready():
	ice_shatter_particles.emitting = true


func _physics_process(_delta: float) -> void:
	if ice_shatter_particles.emitting:
		return
	else:
		self.queue_free()
