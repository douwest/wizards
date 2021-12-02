extends CanvasLayer

var map_index = 0 setget set_map_index
var player_1_character = null
var player_2_character = null
var selected_map = Resources.levels[map_index]

onready var player_1_portrait: TextureRect = $Panel/MenuContainer/ConfigurationContainer/Player1/Portrait
onready var player_2_portrait: TextureRect = $Panel/MenuContainer/ConfigurationContainer/Player2/Portrait

onready var player_1_character_label: Label = $Panel/MenuContainer/ConfigurationContainer/Player1/CharacterName
onready var player_2_character_label: Label = $Panel/MenuContainer/ConfigurationContainer/Player2/CharacterName
onready var selected_map_label: Label = $Panel/MenuContainer/ConfigurationContainer/SelectionContainer/MapSelectionContainer/MapNameLabel

onready var player_1_ready: CheckBox = $Panel/MenuContainer/ConfigurationContainer/Player1/Ready/CheckBox
onready var player_2_ready: CheckBox = $Panel/MenuContainer/ConfigurationContainer/Player2/Ready/CheckBox
onready var start_button: Button = $Panel/MenuContainer/NavigationContainer/StartButton

onready var prevMapBtn: Button = $Panel/MenuContainer/ConfigurationContainer/SelectionContainer/MapSelectionContainer/ButtonContainer/PreviousMapButton
onready var nextMapBtn: Button = $Panel/MenuContainer/ConfigurationContainer/SelectionContainer/MapSelectionContainer/ButtonContainer/NextMapButton


# Lifecycle hooks


func _ready():
	Network.connect("server_closed", self, '_on_server_closed')
	
	if not get_tree().is_network_server():
		prevMapBtn.disabled = true
		nextMapBtn.disabled = true

	update_map()


func _process(_delta):
	if (player_1_ready.pressed and player_2_ready.pressed) or (player_1_character and get_tree().is_network_server()):
		start_button.disabled = false
	else:
		start_button.disabled = true
		
	if player_1_character:
		player_1_ready.disabled = false
	if player_2_character:
		player_2_ready.disabled = false	


# Remote functions


remotesync func set_map_index(value):
	map_index = value
	selected_map = Resources.levels[map_index]
	update_map()


remotesync func update_player_1(character):
	player_1_character = character
	player_1_portrait.texture = load(player_1_character.portrait)
	player_1_character_label.text = player_1_character.name
	if get_tree().is_network_server():
		Gamestate.player_info.character = player_1_character
	

remotesync func update_player_2(character):
	player_2_character = character
	player_2_portrait.texture = load(player_2_character.portrait)
	player_2_character_label.text = player_2_character.name
	if !get_tree().is_network_server():
		Gamestate.player_info.character = player_2_character


remotesync func update_map():
	selected_map_label.text = selected_map.name
	Gamestate.level.name = selected_map.name
	Gamestate.level.actor_path = selected_map.scene


remotesync func start_game():
	get_tree().change_scene("res://Levels/Scenes/Game.tscn")


remote func toggle_p1_ready(ready):
	player_1_ready.pressed = ready
	
	
remote func toggle_p2_ready(ready):
	player_2_ready.pressed = ready
	

# Signals


func _on_PreviousMapButton_pressed():
	rpc('set_map_index', 0)


func _on_NextMapButton_pressed():
	rpc('set_map_index', 1)


func _on_SelectionContainer_character_selected(character):
	if get_tree().is_network_server():
		rpc('update_player_1', character)
	else:
		rpc('update_player_2', character)


func _on_RandomCharacterButton_pressed():
	var character = Resources.characters[randi() % Resources.characters.size()]
	if get_tree().is_network_server():
		rpc('update_player_1', character)
	else:
		rpc('update_player_2', character)


func _on_LeaveButton_pressed():
	if get_tree().is_network_server():
		get_tree().set_network_peer(null)
		get_tree().change_scene("res://Network/Scenes/MainMenu.tscn")
	else:
		Network.unregister_player(Gamestate.player_info.net_id)
		get_tree().set_network_peer(null)
		get_tree().change_scene("res://Network/Scenes/MainMenu.tscn")
	


func _on_StartButton_pressed():
	rpc('start_game')


func _on_server_closed():
	get_tree().set_network_peer(null)
	get_tree().change_scene("res://Network/Scenes/MainMenu.tscn")


func _on_Player1_CheckBox_toggled(button_pressed):
	if player_1_character:
		rpc('toggle_p1_ready', button_pressed)


func _on_Player2_CheckBox_toggled(button_pressed):
	if player_2_character:
		rpc('toggle_p2_ready', button_pressed)

