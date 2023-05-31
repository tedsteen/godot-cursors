extends Entity
class_name StairsDown

const stairs_down_res = preload("res://entities/stairs_down.tscn")

var connected_stairs: StairsUp

static func create(p_connected_stairs: StairsUp) -> StairsDown:
	var stairs_down: StairsDown = stairs_down_res.instantiate()
	stairs_down.connected_stairs = p_connected_stairs
	return stairs_down

func handle_cursors(cursors: Array[Cursor]):
	for cursor in cursors.filter(func(cursor): return cursor.left_clicked):
		print_debug("TODO: Stairs down! ", cursor, connected_stairs.level)
