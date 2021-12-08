extends Area2D


export var bullet_speed = 400
export var damage = 10
var speed = 0
onready var animationPlayer = $AnimationPlayer

<<<<<<< Updated upstream
func _ready():
	animationPlayer.play("Start")

=======
func start(direction: int):
	if(direction < 0):
		rotation_degrees = 180
	animationPlayer.play("Flying")
	
>>>>>>> Stashed changes
func _physics_process(delta):
	position += transform.x * speed * delta

func set_speed_from_direction(direction: int):
	if direction == 1:
		speed = bullet_speed
		$Particles2D.get_process_material().direction.x=-1
	else: 
		speed = -bullet_speed
		$Sprite.scale.x=-1
		$Particles2D.get_process_material().direction.x=1

func _on_Spell_body_entered(body):
	if body.has_method('take_damage'):
		body.take_damage(damage)
	queue_free()
	

func _on_Spell_area_entered(_area):
	queue_free()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name=="Start":
		animationPlayer.play("Flying")
