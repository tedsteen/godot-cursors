extends Node2D
class_name Main

var cursor_res = preload("res://cursor.tscn")

@export var cursor_lifetime = 5
var time
var frame
var current_recording
var cursors: Array[Cursor]

func reset_time():
	time = 0
	frame = 0
	current_recording = cursor_res.instantiate()
	add_child(current_recording)

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
	$"Level/TimeRect".size.y = $"Level/BackgroundRect".size.y * (1 - time / cursor_lifetime)
	#print_debug("Time: %f (frame: %d)" % [time, frame])

func _input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, $"Camera2D".make_input_local(event))

