extends GridContainer

signal character_selected(character)
signal character_focus(character)
signal character_blur()

const RosterButton = preload("res://Static/Resources/UI/RosterButton.tscn")

func _ready():
	for character in Resources.characters:
		var character_button = RosterButton.instance()
		character_button.connect("pressed", self, "on_character_button_pressed", [character])
		character_button.connect("mouse_entered", self, "on_character_button_focus", [character])
		character_button.connect("mouse_exited", self, "on_character_button_blur")
		
		var texture = load(character.portrait)
		
		self.add_child(character_button)
		character_button.set_portrait(texture)		

func on_character_button_pressed(character):
	emit_signal("character_selected", character)
	
func on_character_button_focus(character):
	emit_signal("character_focus", character)
	
func on_character_button_blur():
	emit_signal("character_blur")