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

	func play_frame(frame: int):
		if self.history.has(frame):
			var curr_frame: InputEventMouse = self.history[frame]
			self.cursor_texture.set_position(curr_frame.position)

			var btn1_pressed = curr_frame.button_mask && 1
			var scale = 4 if btn1_pressed else 2
			self.cursor_texture.scale = Vector2(scale, scale)
			self.cursor_texture.show()
			
const cursor_lifetime = 1
var time
var frame
var current_recording
var cursors: Array[Cursor]

func reset_time():
	time = 0
	frame = 0
	current_recording = Cursor.new(self)

func _init():
	cursors = []
	reset_time()

func _physics_process(delta):
	time += delta
	if time >= cursor_lifetime:
		cursors.push_back(current_recording)
		reset_time()

	for cursor in cursors:
		cursor.play_frame(frame)

	frame += 1
	#print_debug("Time: %f (frame: %d)" % [time, frame])

func _input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, event)

