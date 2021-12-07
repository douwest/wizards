extends Node

var characters = [
	{
		name = "Red", 
		portrait = "res://Characters/Sprites/Red/Red_Portrait.png",
		lobby_scene = "res://Characters/Scenes/Red/RedLobby.tscn",		
		scene = "res://Characters/Scenes/Red/Red.tscn"
	},
	{
		name = "Green", 
		portrait = "res://Characters/Sprites/Green/Green_Portrait.png",
		lobby_scene = "",
		scene = "res://Characters/Scenes/Green/Green.tscn"
	},
#	{
#		name = "Warlock", 
#		portrait = "res://Characters/Sprites/Warlock/Warlock_Portrait.png",
#		scene = "res://Characters/Scenes/Warlock/Warlock.tscn"
#	}
]

var levels = [
	{
		name = "Nature Shrine",
		scene = "res://Levels/Scenes/NatureShrine.tscn"
	},
	{
		name = "Test Level",
		scene = 'res://Levels/Scenes/TestLevel.tscn'
	},
	{
		name = "Village",
		scene = 'res://Levels/Scenes/Village.tscn'
	}
]
