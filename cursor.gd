extends TextureRect
class_name Cursor

@export var cursor_click_size = 0.7

var history = {}

func record_frame(frame: int, mouse_event: InputEventMouse):
	#print_debug("record frame %s, %s", mouse_event)
	self.history[frame] = mouse_event

func play_frame(frame: int, camera: Camera2D) -> InputEventMouse:
	if self.history.has(frame):
		var curr_frame: InputEventMouse = self.history[frame]
		self.set_position(camera.make_input_local(curr_frame).position)

		var btn1_pressed = curr_frame.button_mask && 1
		var texture_scale = cursor_click_size if btn1_pressed else 1.0

		self.scale = Vector2(texture_scale, texture_scale)
		return curr_frame
	return null
