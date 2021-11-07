extends CanvasLayer


func _ready():
	Network.connect('server_created', self, '_on_ready_to_play')
	Network.connect("join_success", self, "_on_ready_to_play")
	Network.connect("join_fail", self, "_on_join_fail")


func _on_ready_to_play():
	get_tree().change_scene("res://Level.tscn")


func _on_Create_pressed():
	Network.create_server()


func _on_Join_pressed():
	Network.join_server()
	

func _on_join_fail():
	print("Failed to join server")
