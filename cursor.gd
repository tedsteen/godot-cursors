extends TextureRect
class_name Cursor

@export var cursor_size = 1.0
@export var cursor_click_size = 1.5

var history = {}

func record_frame(frame: int, mouse_event: InputEventMouse):
	#print_debug("record frame %s, %s", mouse_event)
	self.history[frame] = mouse_event

func play_frame(frame: int):
	if self.history.has(frame):
		var curr_frame: InputEventMouse = self.history[frame]
		self.set_position(curr_frame.position)

		var btn1_pressed = curr_frame.button_mask && 1
		var texture_scale = cursor_click_size if btn1_pressed else cursor_size
		texture_scale *= 0.4
		self.scale = Vector2(texture_scale, texture_scale)
		self.show()
		
