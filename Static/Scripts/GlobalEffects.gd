extends Node


# Global camera shake effect, strength dependent on distance player to impact position
remotesync func screen_shake(characters, duration, frequency, amplitude, priority, impact_position) -> void:
	for character in characters:
		if character is Character:
			var impact_strength = 1 - clamp((abs(character.global_position.distance_to(impact_position)) / 256), 0, 1)
			character.camera.screen_shake.start(duration, frequency, impact_strength * amplitude, priority)
