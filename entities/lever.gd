extends Entity

class_name Lever

const lever_res = preload("res://entities/lever.tscn")

@onready var open_audio = %OpenAudio

var is_pulled = false : set = set_is_pulled

signal pulled(pulled: bool)

static func create() -> Lever:
	var lever = lever_res.instantiate()
	lever.add_to_group("levers")
	return lever	

func handle_cursors(cursors: Array[Cursor]):
	is_pulled = cursors.any(func(cursor): return cursor.left_pressed)

func set_is_pulled(p_is_pulled: bool):
	if is_pulled != p_is_pulled:
		is_pulled = p_is_pulled
		if is_pulled:
			open_audio.play()
			sprite.play("default")
		else:
			sprite.play_backwards("default")
		emit_signal("pulled", is_pulled)
