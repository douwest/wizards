extends Area2D
class_name KinematicSpell


signal completed

export var speed = 500
export var damage = 99

var direction = 1


# Called when the node enters the scene tree for the first time.
func init(input_position: Vector2, dir: int, node: Node) -> void:
	position = input_position
	direction = dir
	node.call_deferred('add_child', self)


func _physics_process(delta: float) -> void:
	position.x = position.x + (direction * speed * delta)


func _on_KinematicSpell_tree_entered():
	emit_signal('completed')


func _on_KinematicSpell_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage(damage)
	self.queue_free()


func _on_KinematicSpell_area_entered(area):
	self.queue_free()
