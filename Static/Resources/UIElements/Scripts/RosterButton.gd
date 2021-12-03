class_name RosterButton
extends TextureButton

onready var portrait = $Portrait

func set_portrait(resource: Texture):
	portrait.set_texture(resource)
