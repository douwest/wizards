extends Node
class_name KinematicSpellFactory

var kinematic_spell = preload("res://Spells/Scenes/Damage/KinematicSpell.tscn")

export (PackedScene) var impact_effect = null
export (PackedScene) var spell_particle = null
export var speed = 500
export var damage = 10

func new() -> KinematicSpell:
	var spell_instance: KinematicSpell = kinematic_spell.instance()
	spell_instance.impact_effect = impact_effect
	spell_instance.spell_particle = spell_particle
	spell_instance.speed = speed
	spell_instance.damage = damage
	return spell_instance


