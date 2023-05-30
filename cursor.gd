extends TextureRect
class_name Cursor

const cursor_res = preload("res://cursor.tscn")

@export var cursor_click_size = 0.7

var history = {}
var left_pressed = false
var left_clicked = false
var level: Level
var _goto_next_level: Callable

static func create(p_level: Level, p_position: Vector2, p_goto_next_level: Callable) -> Cursor:
	var cursor: Cursor = cursor_res.instantiate()
	cursor.level = p_level
	cursor.position = p_position
	cursor._goto_next_level = p_goto_next_level
	cursor.level.add_child(cursor)
	return cursor

func record_frame(frame: int, mouse_event: InputEventMouse):
	self.history[frame] = mouse_event

func play_frame(frame: int):
	if self.history.has(frame):
		var curr_frame: InputEventMouse = self.history[frame]
		self.set_position(curr_frame.position)

		if curr_frame is InputEventMouseButton:
			left_pressed = curr_frame.button_index == MouseButton.MOUSE_BUTTON_LEFT and curr_frame.pressed
			left_clicked = left_pressed 
		var texture_scale = cursor_click_size if left_pressed else 1.0

		self.scale = Vector2(texture_scale, texture_scale)
		return
	left_clicked = false

func goto_next_level():
	_goto_next_level.call(self)
