extends Entity
class_name StairsUp

@onready var next_level_audio = %NextLevelAudio

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		next_level_audio.play()
