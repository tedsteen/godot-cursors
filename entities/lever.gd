extends Entity

class_name Lever

const lever_res = preload("res://entities/lever.tscn")

@onready var open_audio = %OpenAudio

var down_btn_counter = 0
var is_pulled = false : set = set_is_pulled

signal pulled(pulled: bool)

static func create() -> Lever:
	var lever = lever_res.instantiate()
	lever.add_to_group("levers")
	return lever	

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.pressed:
			down_btn_counter += 1
		else:
			down_btn_counter -= 1
		is_pulled = down_btn_counter > 0

func set_is_pulled(p_is_pulled: bool):
	if is_pulled != p_is_pulled:
		is_pulled = p_is_pulled
		if is_pulled:
			open_audio.play()
			sprite.play("default")
		else:
			sprite.play_backwards("default")
		emit_signal("pulled", is_pulled)
