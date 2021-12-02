extends CanvasLayer

var map_index = 0 setget set_map_index
var player_1_character = Resources.characters[0]
var player_2_character = Resources.characters[1]
var selected_map = Resources.levels[map_index]

onready var player_1_portrait: TextureRect = $Panel/ConfigurationContainer/Player1/Portrait
onready var player_2_portrait: TextureRect = $Panel/ConfigurationContainer/Player2/Portrait

onready var player_1_character_label: Label = $Panel/ConfigurationContainer/Player1/CharacterName
onready var player_2_character_label: Label = $Panel/ConfigurationContainer/Player2/CharacterName
onready var selected_map_label: Label = $Panel/ConfigurationContainer/SelectionContainer/MapSelectionContainer/MapNameLabel

onready var player_1_ready: CheckBox = $Panel/ConfigurationContainer/Player1/Ready/CheckBox
onready var player_2_ready: CheckBox = $Panel/ConfigurationContainer/Player2/Ready/CheckBox


func _ready():
	if ! get_tree().is_network_server():
		$Panel/ConfigurationContainer/SelectionContainer/MapSelectionContainer/ButtonContainer/PreviousMapButton.disabled = true
		$Panel/ConfigurationContainer/SelectionContainer/MapSelectionContainer/ButtonContainer/NextMapButton.disabled = true
		player_1_ready.disabled = true
	else:
		player_2_ready.disabled = true
	update_player_1([player_1_character])
	update_player_2([player_2_character])
	update_map()


func set_map_index(value):
	map_index = value
	selected_map = Resources.levels[map_index]
	update_map()


# Should be updated to selection of player that created server
remotesync func update_player_1(args):
	print('update player 1', args[0])	
	player_1_character = args[0]
	player_1_portrait.texture = load(player_1_character.portrait)
	player_1_character_label.text = player_1_character.name
	if get_tree().is_network_server():
		Gamestate.player_info.actor_path = player_1_character.scene
	

# Should be updated to selection of player that joined server
remotesync func update_player_2(args):
	print('update player 2', args[0])
	player_2_character = args[0]
	player_2_portrait.texture = load(player_2_character.portrait)
	player_2_character_label.text = player_2_character.name
	if !get_tree().is_network_server():
		Gamestate.player_info.actor_path = player_2_character.scene


remote func update_map():
	selected_map_label.text = selected_map.name
	Gamestate.level.name = selected_map.name
	Gamestate.level.actor_path = selected_map.scene


func _on_PreviousMapButton_pressed():
	set_map_index(0)


func _on_NextMapButton_pressed():
	set_map_index(1)


func _on_SelectionContainer_character_selected(character):
	# If I called this
	# if i am the server - i should update player 1 and rpc to others that player 1 has been updated - done with remote
	# if i am a client - i should update player 2 and rpc to others that player 2 has been updated - done with remote
	if get_tree().is_network_server():
		rpc('update_player_1', [character])
	else:
		rpc('update_player_2', [character])


func _on_RandomCharacterButton_pressed():
	# If I called this
	# if i am the server - i should update player 1 and rpc to others that player 1 has been updated - done with remote
	# if i am a client - i should update player 2 and rpc to others that player 2 has been updated - done with remote
	var character = Resources.characters[randi() % Resources.characters.size()]
	if get_tree().is_network_server():
		rpc('update_player_1', [character])
	else:
		rpc('update_player_2', [character])