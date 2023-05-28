extends Entity
class_name Gem

@onready var checkpoint_audio = %CheckpointAudio

func handle_mouse(event: InputEventMouse):
	if checkpoint_audio.has_stream_playback(): return
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		checkpoint_audio.play()
		hide()
		await checkpoint_audio.finished
		queue_free()
