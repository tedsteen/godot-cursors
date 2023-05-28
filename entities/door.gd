extends Entity
class_name Door

@onready var open_audio = %OpenAudio
@onready var close_audio = %CloseAudio
@onready var closed_click_audio = %ClosedClickAudio

var open = false: set = set_open
var available = true : set = set_available
var locked = false : set = set_locked

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		if !open:
			closed_click_audio.play()
		else:
			print_debug("TODO: goto next level!")

func set_locked(p_locked: bool):
	if locked != p_locked:
		locked = p_locked
		set_open(available && !locked)

func set_available(p_available: bool):
	if available != p_available:
		available = p_available
		set_open(available && !locked)

func set_open(p_open: bool):
	if open != p_open:
		open = p_open
		print_debug("OPEN ", open)
		if open:
			open_audio.play()
			$AnimatedSprite2D.play("default")
		else:
			$AnimatedSprite2D.play_backwards("default")
			await $AnimatedSprite2D.animation_finished
			close_audio.play()
