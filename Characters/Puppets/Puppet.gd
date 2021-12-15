extends Actor


export var health = 10

func _ready() -> void:
	pass
	
func _physics_process(_delta) -> void:
	if health <= 0:
		self.queue_free()
	
func take_damage(damage):
	health -= damage
