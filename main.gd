extends Node2D

const cursor_res = preload("res://cursor.tscn")

class Cursor:
	var cursor_texture: TextureRect
	var history = {}

	func _init(parent: Node):
		self.cursor_texture = cursor_res.instantiate()
		parent.add_child(self.cursor_texture)

	func record_frame(frame: int, mouse_event: InputEventMouse):
		#print_debug("record frame %s, %s", mouse_event)
		self.history[frame] = mouse_event

	func set_frame(frame: int):
		if self.history.has(frame):
			var curr_frame: InputEventMouse = self.history[frame]
			self.cursor_texture.set_position(curr_frame.position)

			var btn1_pressed = curr_frame.button_mask && 1
			if btn1_pressed:
				self.cursor_texture.scale = Vector2(4, 4)
			elif !btn1_pressed:
				self.cursor_texture.scale = Vector2(2, 2)
			
			self.cursor_texture.show()
			
const cursor_lifetime = 1
var time = cursor_lifetime
var frame = 0
var current_recording = Cursor.new(self)
var cursors: Array[Cursor] = []

func _physics_process(delta):
	time -= delta
	if time <= 0:
		time = cursor_lifetime
		frame = 0
		cursors.push_back(current_recording)
		current_recording = Cursor.new(self)

	for cursor in cursors:
		cursor.set_frame(frame)

	#print_debug("Time: %f" % rough_time)
	frame += 1

func _unhandled_input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, event)

