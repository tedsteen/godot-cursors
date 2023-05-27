extends Node2D
var cursor_res = preload("res://cursor.tscn")
var pot_res = preload("res://entities/pot.tscn")
var door_res = preload("res://entities/door.tscn")
var rng: RandomNumberGenerator

@onready var background_rect = $Container/BackgroundRect
@onready var time_rect = $Container/TimeRect
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var dss: = get_world_2d().direct_space_state

@export var cursor_lifetime = 5
@export var map_seed = 1

var time
var frame
var current_recording: Cursor
var cursors: Array[Cursor]
var entities: Array[Entity]

var point_params: = PhysicsPointQueryParameters2D.new()

const CELL_SIZE = 90

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = map_seed
	point_params.collide_with_areas = true #set it up
	#point_params.collision_mask = 2
	cursors = []
	reset_time(true)

func generate_map_data(difficulty: int, amount: int) -> Array[Dictionary]:
	var width = int(background_rect.size.x / CELL_SIZE)
	var height = int(background_rect.size.y / CELL_SIZE)
	
	var available_stuff: Array[Dictionary] = []
	var free_slots: Array = range(0, width*height)
	
	for i in range(0, amount):
		available_stuff.append({"type": "pot", "health": rng.randi() % difficulty + 1 })
	
	available_stuff.append({ "type": "door" })
	
	if available_stuff.size() > width * height:
		push_error("Can't fit content on map.")
		return []
	
	var map_data: Array[Dictionary] = []
	for stuff in available_stuff:
		var idx = rng.randi() % free_slots.size()
		var coord = free_slots[idx]
		stuff["position"] = Vector2((coord % width) * CELL_SIZE, int(coord / width) * CELL_SIZE)
		map_data.append(stuff)
		free_slots.remove_at(idx)

	return map_data

func reset_time(new_pots: bool):
	time = 0
	frame = 0
	if current_recording: current_recording.show()
	current_recording = cursor_res.instantiate()
	current_recording.position = get_global_mouse_position()
	current_recording.hide()
	add_child(current_recording)

	if new_pots:
		for entity in entities:
			if entity is Pot:
				remove_child(entity)
		for map_data in generate_map_data(100, 10):
			var position = map_data.position
			if map_data.type == "pot":
				var pot: Pot = pot_res.instantiate()
				pot.position = position
				entities.append(pot)
				add_child(pot)
				pot.health = map_data.health
			elif map_data.type == "door":
				var door: Door = door_res.instantiate()
				door.position = position
				entities.append(door)
				add_child(door)
				
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
			var entity = hit.collider
			if entity is Pot:
				entity.take_damage()
			elif entity is Door:
				print_debug("Knock...")

func _input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, event)
		handle_click(event)
	
