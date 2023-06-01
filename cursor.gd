extends TextureRect
class_name Cursor

const cursor_res = preload("res://cursor.tscn")

@export var cursor_click_size = 0.7

var history = {}
var start_position: Vector2
var left_pressed = false
var left_clicked = false
var level: Level: set = set_level
var spawn_level_idx: int

static func create(p_level: Level, p_spawn_level_idx: int, p_position: Vector2) -> Cursor:
	var cursor: Cursor = cursor_res.instantiate()
	cursor.position = p_position
	cursor.start_position = p_position
	cursor.level = p_level
	cursor.spawn_level_idx = p_spawn_level_idx
	cursor.add_to_group("cursors")
	return cursor

func restart(p_level: Level):
	level = p_level
	left_pressed = false
	left_clicked = false
	position = start_position
	
func set_level(new_level: Level):
	if level:
		level.remove_child(self)
		level.cursors.erase(self)
	if new_level:
		new_level.add_child(self)
		new_level.cursors.append(self)
	level = new_level

func record_frame(frame: int):
	self.history[frame] = { "position": position, "left_pressed": left_pressed, "left_clicked": left_clicked }

func play_frame(frame: int):
	var item: Dictionary = self.history[frame]
	self.position = item.position
	left_pressed = item.left_pressed
	left_clicked = item.left_clicked
	
	var texture_scale = cursor_click_size if left_pressed else 1.0

	self.scale = Vector2(texture_scale, texture_scale)
