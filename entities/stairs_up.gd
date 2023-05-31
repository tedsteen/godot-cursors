extends Entity
class_name StairsUp

const stairs_up_res = preload("res://entities/stairs_up.tscn")
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var next_level_audio = %NextLevelAudio
var goto_next_level: Callable
var level: Level
var connected_stairs: StairsDown

static func create(p_goto_next_level: Callable, p_level: Level) -> StairsUp:
	var stairs_up: StairsUp = stairs_up_res.instantiate()
	stairs_up.add_to_group("up_stairs")
	
	stairs_up.goto_next_level = p_goto_next_level.bind(stairs_up)
	stairs_up.level = p_level
	stairs_up.connected_stairs = StairsDown.create(stairs_up)
	return stairs_up

func _physics_process(_delta):
	#print_debug("TED", get_parent().get_parent().position)
	#connected_stairs.position = get_parent().get_parent().position
	pass

func handle_cursors(cursors: Array[Cursor]):
	var clicked_cursors = cursors.filter(func(cursor: Cursor): return cursor.left_clicked)
	if clicked_cursors.size() > 0:
		next_level_audio.play()
	for cursor in clicked_cursors:
		goto_next_level.call(cursor)
