extends MarginContainer

const random_character_description = "Random"

onready var tooltipLabel = $Tooltip

signal character_selected(character)

func _ready():
	tooltipLabel.text = ""


func _on_Roster_character_blur():
	tooltipLabel.text = ""


func _on_Roster_character_focus(character):
	tooltipLabel.text = character.name


func _on_Roster_character_selected(character):
	emit_signal("character_selected", character)


func _on_RandomCharacterButton_mouse_entered():
	tooltipLabel.text = random_character_description
