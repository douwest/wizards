extends CanvasLayer


var base_scene_path = "res://Characters/Scenes/"
var base_sprite_path = "res://Characters/Sprites/"

var character_scene_paths = [
	"Abstract/Character.tscn",
	"Red/Red.tscn"
]

var character_sprite_paths = [
	"Abstract/Template-Spritesheet.png",
	"Red/Red.png"
]

var character_names = [
	"Template Character",
	"Red the Wise"
]

var selected_character = 0 setget set_selected_character
var selected_character_scene = base_scene_path + character_scene_paths[0]

onready var ip_address = $Panel/Menu/InputFields/IPAddressInputField
onready var port_number = $Panel/Menu/InputFields/PortNumberInputField
onready var join_button = $Panel/Menu/InputButtons/Join

onready var selected_character_sprite = $Panel/CharacterSelectContainer/PortraitContainer/Portrait/Sprite
onready var selected_character_label = $Panel/CharacterSelectContainer/PortraitContainer/CharacterName

func _ready():
	selected_character_label.text = character_names[selected_character]
	Network.connect('server_created', self, '_on_ready_to_play')
	Network.connect("join_success", self, "_on_ready_to_play")
	Network.connect("join_fail", self, "_on_join_fail")


func _process(delta):
	if !ip_address.text or !port_number.text:
		join_button.disabled = true
	else:
		join_button.disabled = false


func _on_ready_to_play():
	get_tree().change_scene("res://Level.tscn")


func _on_PreviousButton_pressed():
	if(selected_character == 0):
		set_selected_character(character_scene_paths.size() - 1)
	else:
		set_selected_character(selected_character - 1)

func _on_NextButton_pressed():
	if(selected_character == character_scene_paths.size() - 1):
		set_selected_character(0)
	else:
		set_selected_character(selected_character + 1)


func _on_Create_pressed():
	Network.create_server()


func _on_Join_pressed():
	Network.join_server(ip_address.text, int(port_number.text))


func set_selected_character(value):
	selected_character = value
	selected_character_scene = base_scene_path + character_scene_paths[selected_character]	
	selected_character_sprite.texture = load(base_sprite_path + character_sprite_paths[selected_character])
	selected_character_label.text = character_names[selected_character]
	Gamestate.player_info.actor_path = selected_character_scene
	print(Gamestate.player_info.actor_path)
	
