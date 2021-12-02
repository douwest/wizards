extends CanvasLayer

onready var ip_address = $StartScreen/VBoxContainer/Menu/InputFields/IPAddressInputField
onready var port_number = $StartScreen/VBoxContainer/Menu/InputFields/PortNumberInputField
onready var join_button = $StartScreen/VBoxContainer/Menu/InputButtons/Join

func _ready():
	Network.connect('server_created', self, '_on_ready_to_play')
	Network.connect("join_success", self, "_on_ready_to_play")
	Network.connect("join_fail", self, "_on_join_fail")


func _process(_delta):
	if !ip_address.text or !port_number.text:
		join_button.disabled = true
	else:
		join_button.disabled = false


func _on_ready_to_play():
	get_tree().change_scene("res://CharacterSelection.tscn")


func _on_Create_pressed():
	Network.create_server()


func _on_Join_pressed():
	Network.join_server(ip_address.text, int(port_number.text))
