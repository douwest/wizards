class_name Stats
extends Node


export var max_health = 10
var current_health = 0 setget set_current_health
var lives = 999


func _ready():
	current_health = max_health


func set_current_health(value):
	current_health = min(max_health, value)
