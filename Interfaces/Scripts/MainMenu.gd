extends CanvasLayer

onready var ip_address = $StartScreen/Panel/VBoxContainer/Menu/InputFields/IPAddressInputField
onready var join_button = $StartScreen/Panel/VBoxContainer/Menu/InputButtons/Join
onready var canvas_modulate = $LightningEffect
onready var ambient_sound_player = $AmbientSoundPlayer
onready var lightning_sound_player = $LightningSoundPlayer
onready var animation_player = $AnimationPlayer

var effect_processing = false
var show_effect = false
var canvas_modifier = 1

var lightning_random_divisor = 320

func _ready():
	randomize()
	
	$Fader.visible = false
	ambient_sound_player.play()
	
	var error = null
	error = Network.connect('server_created', self, '_on_ready_to_play')
	error = Network.connect("join_success", self, "_on_ready_to_play")
	error = Network.connect("join_fail", self, "_on_join_fail")
	if error:
		print(error)
		

func _physics_process(_delta):
	if !ip_address.text:
		join_button.disabled = true
	else:
		join_button.disabled = false
		
	show_effect = randi() % lightning_random_divisor == 1
	
	if show_effect and not effect_processing:
		lightning_sound_player.play(4 + randf() * 1.5)
		effect_processing = true
		canvas_modifier = 3
		
	if effect_processing:
		canvas_modifier = max(canvas_modifier - 0.2, 1)
		if canvas_modifier <= 1:
			effect_processing = false
			
	canvas_modulate.color = Color(canvas_modifier, canvas_modifier, canvas_modifier, 1)


func _on_ready_to_play():
	animation_player.play('fade_out')


func _on_Create_pressed():
	Network.create_server()


func _on_Join_pressed():
	Network.join_server(ip_address.text, Network.server_info.used_port)


func _on_ExitGameButton_pressed():
	get_tree().quit(-1)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'fade_out':
		var error = get_tree().change_scene("res://Interfaces/Scenes/CharacterSelection.tscn")
		if error:
			print(error)
	else:
		pass
