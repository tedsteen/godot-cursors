extends TextureRect
class_name Cursor

const cursor_res = preload("res://cursor.tscn")

@export var cursor_click_size = 0.7

var history = {}
static func create(position: Vector2, visible: bool) -> Cursor:
	var cursor: Cursor = cursor_res.instantiate()
	cursor.position = position
	cursor.visible = visible
	return cursor

func record_frame(frame: int, mouse_event: InputEventMouse):
	self.history[frame] = mouse_event

func play_frame(frame: int) -> InputEventMouse:
	if self.history.has(frame):
		var curr_frame: InputEventMouse = self.history[frame]
		self.set_position(curr_frame.position)

		var left_pressed = curr_frame is InputEventMouseButton and curr_frame.button_index == MouseButton.MOUSE_BUTTON_LEFT and curr_frame.pressed
		var texture_scale = cursor_click_size if left_pressed else 1.0

		self.scale = Vector2(texture_scale, texture_scale)
		return curr_frame
	return null
