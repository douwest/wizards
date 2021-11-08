extends CanvasLayer


onready var ip_address = $Panel/VBoxContainer/IPAddressInputField
onready var port_number = $Panel/VBoxContainer/PortNumberInputField
onready var join_button = $Panel/VBoxContainer/HBoxContainer/Join

func _ready():
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


func _on_Create_pressed():
	Network.create_server()


func _on_Join_pressed():
	Network.join_server(ip_address.text, int(port_number.text))
	

func _on_join_fail():
	print("Failed to join server")
