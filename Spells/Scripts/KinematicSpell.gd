extends Area2D
class_name KinematicSpell


onready var collision_shape: CollisionShape2D = $CollisionShape2D

export var initial_speed = 500
export var max_speed = 500
export var acceleration = 0
export var damage = 10

var speed = 0

var impact_effect = null
var spell_particle = null # The scene containing the moving object (sprite, maybe a light etc.)

var direction = 1
var attached_node: Node = null

# Called when the node enters the scene tree for the first time.
func init(input_position: Vector2, dir: int, node: Node) -> void:
	speed = initial_speed
	attached_node = node
	attached_node.add_child(self)
	position = input_position
	direction = dir
	if spell_particle:
		add_child(spell_particle.instance())

func _physics_process(delta: float) -> void:
	if speed < max_speed:
		speed += acceleration
	position.x = position.x + (direction * speed * delta)
	

func spawn_impact_effect() -> void:
	var impact_effect_instance = impact_effect.instance()
	impact_effect_instance.global_position = self.position
	attached_node.add_child(impact_effect_instance)

func _on_KinematicSpell_body_entered(body):
	if body.has_method('take_damage'):
		var hit_position = Vector2(body.position.x, self.position.y)
		body.take_damage(damage, hit_position, Vector3(-1 * direction, 0, 0))
	GlobalEffects.rpc("screen_shake", attached_node.get_characters(), 0.15, 20, 20, 0, self.position)
	spawn_impact_effect()
	self.queue_free()


func _on_KinematicSpell_area_entered(_area):
	GlobalEffects.rpc("screen_shake", attached_node.get_characters(), 0.15, 20, 20, 0, self.position)
	spawn_impact_effect()
	self.queue_free()
