extends Entity
class_name StairsUp

const stairs_up_res = preload("res://entities/stairs_up.tscn")

@onready var next_level_audio = %NextLevelAudio
var goto_next_level: Callable

static func create(p_goto_next_level: Callable) -> StairsUp:
	var stairs_up: StairsUp = stairs_up_res.instantiate()
	stairs_up.add_to_group("up_stairs")
	stairs_up.goto_next_level = p_goto_next_level
	return stairs_up

func handle_cursors(cursors: Array[Cursor]):
	var clicked_cursors = cursors.filter(func(cursor: Cursor): return cursor.left_clicked)
	if clicked_cursors.size() > 0:
		next_level_audio.play()
	for cursor in clicked_cursors:
		goto_next_level.call(cursor)
