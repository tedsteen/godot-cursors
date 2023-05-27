extends Node2D
var cursor_res = preload("res://cursor.tscn")
var pot_res = preload("res://pot.tscn")

@onready var background_rect = $Container/BackgroundRect
@onready var time_rect = $Container/TimeRect
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var dss: = get_world_2d().direct_space_state

@export var cursor_lifetime = 5
var time
var frame
var current_recording: Cursor
var cursors: Array[Cursor]
var pots: Array[Pot]
var point_params: = PhysicsPointQueryParameters2D.new()

const CELL_SIZE = 90

func generate_pot_data(difficulty: int, amount: int) -> Array[Dictionary]:
	var available_data: Array[Dictionary] = []
	for x in range(0, background_rect.size.x / CELL_SIZE):
		for y in range(0, background_rect.size.y / CELL_SIZE):
			var data = { "health": randi() % difficulty + 1, "position": Vector2(x * CELL_SIZE, y * CELL_SIZE) }
			available_data.append(data)

	var pot_data: Array[Dictionary] = []
	if amount > available_data.size():
		push_warning("Can't generate %d pots, there are only %d available." % [amount, available_data.size()])
		amount = available_data.size()
	for i in range(0, amount):
		var x = randi() % available_data.size()
		pot_data.append(available_data[x])
		available_data.remove_at(x)
		
	return pot_data

func reset_time(new_pots: bool):
	time = 0
	frame = 0
	if current_recording: current_recording.show()
	current_recording = cursor_res.instantiate()
	current_recording.position = get_global_mouse_position()
	current_recording.hide()
	add_child(current_recording)

	if new_pots:
		for pot in pots:
			remove_child(pot)
		for pot_data in generate_pot_data(100, 4):
			var pot: Pot = pot_res.instantiate()
			pot.position = pot_data.position
			pots.append(pot)
			add_child(pot)
			pot.health = pot_data.health

func _ready():
	point_params.collide_with_areas = true #set it up
	#point_params.collision_mask = 2
	cursors = []
	reset_time(true)

func _physics_process(delta):	
	time += delta
	if time >= cursor_lifetime:
		cursors.push_back(current_recording)
		reset_time(false)

	for cursor in cursors:
		var event = cursor.play_frame(frame, %Camera2D)
		handle_click(event)
	
	frame += 1
	time_rect.size.y = background_rect.size.y * (1 - time / cursor_lifetime)
	#print_debug("Time: %f (frame: %d)" % [time, frame])

func handle_click(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		point_params.position = event.position * view_to_world
		var hits = dss.intersect_point(point_params)
		for hit in hits:
			var pot: Pot = hit.collider
			pot.take_damage()

func _input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, event)
		handle_click(event)
	
