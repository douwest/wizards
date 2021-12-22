extends Node

const TRANS : int = Tween.TRANS_SINE
const EASE : int = Tween.EASE_IN_OUT

var amplitude : float = 16
var priority : int = 0

onready var camera : Camera2D = get_parent()
onready var frequency : Timer = $Frequency
onready var duration : Timer = $Duration
onready var shake_tween : Tween = $ShakeTween


func start(_duration = 0.2, _frequency = 15, _amplitude = 16, _priority = 0) -> void:
	
	if priority >= self.priority:
		self.priority = _priority
		self.amplitude = _amplitude
		
		duration.wait_time = _duration
		frequency.wait_time = 1 / float(_frequency)
		duration.start()
		frequency.start()
		
		new_shake()


func new_shake() -> void:
	var rand = Vector2()
	rand.x = rand_range(-amplitude, amplitude)
	rand.y = rand_range(-amplitude, amplitude)
	
	var _err = shake_tween.interpolate_property(
		camera, 
		"offset", 
		camera.offset, 
		rand, 
		frequency.wait_time, 
		TRANS, 
		EASE
	)
	_err = shake_tween.start()


func reset() -> void:
	var _err = shake_tween.interpolate_property(
		camera, 
		"offset", 
		camera.offset, 
		Vector2.ZERO, 
		frequency.wait_time, 
		TRANS, 
		EASE
	)
	_err = shake_tween.start()
	self.priority = 0


func _on_Frequency_timeout():
	new_shake()


func _on_Duration_timeout():
	reset()
	frequency.stop()
