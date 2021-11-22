extends GridContainer


func _ready():
	for character in Characters.resources:
		var character_button = TextureButton.new()
		var texture = load(character.portrait)
		character_button.texture_normal = texture
		self.add_child(character_button)
