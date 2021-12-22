extends Area2D
class_name KinematicSpell


signal completed

onready var collision_shape: CollisionShape2D = $CollisionShape2D

export var speed = 500
export var damage = 10
export (PackedScene) var impact_effect = null

var direction = 1
var attached_node: Node = null

# Called when the node enters the scene tree for the first time.
func init(input_position: Vector2, dir: int, node: Node) -> void:
	attached_node = node
	position = input_position
	direction = dir
	node.call_deferred('add_child', self)


func _physics_process(delta: float) -> void:
	position.x = position.x + (direction * speed * delta)


func spawn_impact_effect() -> void:
	var impact_effect_instance = impact_effect.instance()
	impact_effect_instance.global_position = self.position
	attached_node.add_child(impact_effect_instance)

func _on_KinematicSpell_body_entered(body):
	if body.has_method('take_damage'):
		var hit_position = Vector2(body.position.x, self.position.y)
		body.take_damage(damage, hit_position, Vector3(-1 * direction, 0, 0))
	GlobalEffects.rpc("screen_shake", get_parent().get_characters(), 0.15, 20, 20, 0, self.position)
	spawn_impact_effect()
	self.queue_free()


func _on_KinematicSpell_area_entered(_area):
	GlobalEffects.rpc("screen_shake", get_parent().get_characters(), 0.15, 20, 20, 0, self.position)
	spawn_impact_effect()
	self.queue_free()


func _on_KinematicSpell_tree_entered():
	emit_signal('completed')
