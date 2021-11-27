extends CanvasLayer

var index = 0 setget set_index
var map_index = 0 setget set_map_index
var selected_character = Resources.characters[index]
var selected_map = Resources.levels[map_index]

onready var ip_address = $Panel/Menu/InputFields/IPAddressInputField
onready var port_number = $Panel/Menu/InputFields/PortNumberInputField
onready var join_button = $Panel/Menu/InputButtons/Join

onready var selected_character_sprite = $Panel/CharacterSelectContainer/PortraitContainer/Portrait/Sprite
onready var selected_character_label = $Panel/CharacterSelectContainer/PortraitContainer/CharacterName
onready var selected_map_label = $Panel/MapSelectionContainer/Label


func _ready():
	selected_character_label.text = selected_character.name
	selected_map_label.text = selected_map.name
	Network.connect('server_created', self, '_on_ready_to_play')
	Network.connect("join_success", self, "_on_ready_to_play")
	Network.connect("join_fail", self, "_on_join_fail")


func _process(delta):
	if !ip_address.text or !port_number.text:
		join_button.disabled = true
	else:
		join_button.disabled = false


func _on_ready_to_play():
	get_tree().change_scene("res://Levels/Scenes/Game.tscn")


func _on_PreviousButton_pressed():
	if(index == 0):
		set_index(Resources.characters.size() - 1)
	else:
		set_index(index - 1)

func _on_NextButton_pressed():
	if(index == Resources.characters.size() - 1):
		set_index(0)
	else:
		set_index(index + 1)


func _on_Create_pressed():
	Network.create_server()


func _on_Join_pressed():
	Network.join_server(ip_address.text, int(port_number.text))


func set_index(value):
	print(value)
	index = value
	selected_character = Resources.characters[index]
	selected_character_sprite.texture = load(selected_character.portrait)
	selected_character_label.text = selected_character.name
	Gamestate.player_info.actor_path = selected_character.scene
	print(Gamestate.player_info.actor_path)
	
func set_map_index(value):
	print(value)
	map_index = value
	selected_map = Resources.levels[map_index]
	selected_map_label.text = selected_map.name
	Gamestate.level.name = selected_map.name
	Gamestate.level.actor_path = selected_map.scene
	

func _on_PreviousMapButton_pressed():
	set_map_index(0)

func _on_NextMapButton_pressed():
	set_map_index(1)
