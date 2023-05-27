extends Node2D
var cursor_res = preload("res://cursor.tscn")
var pot_res = preload("res://entities/pot.tscn")
var door_res = preload("res://entities/door.tscn")
var gem_res = preload("res://entities/gem.tscn")

var rng: RandomNumberGenerator

@onready var background_rect = %BackgroundRect
@onready var time_rect = %TimeRect
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var dss: = get_world_2d().direct_space_state

@export var cursor_lifetime = 5
@export var map_seed = 1

var time
var frame
var current_recording: Cursor
var cursors: Array[Cursor]

var point_params: = PhysicsPointQueryParameters2D.new()

const CELL_SIZE = 90

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = map_seed
	point_params.collide_with_areas = true
	#point_params.collision_mask = 2
	cursors = []
	reset_time(true)

func generate_map_data(difficulty: int, amount: int):	
	var available_entities: Array[Entity] = []

	for i in range(0, amount):
		var pot: Pot = pot_res.instantiate()
		pot.health = rng.randi() % difficulty + 1
		available_entities.append(pot)

	available_entities.append(door_res.instantiate())
	available_entities.append(gem_res.instantiate())
	
	var width = int(background_rect.size.x / CELL_SIZE)
	var height = int(background_rect.size.y / CELL_SIZE)

	if available_entities.size() > width * height:
		push_error("Can't fit content on map.")
		return
	
	var free_slots: Array = range(0, width * height)
	var map_data: Array[Dictionary] = []
	for entity in available_entities:
		var idx = rng.randi() % free_slots.size()
		var coord = free_slots[idx]
		entity.position = Vector2((coord % width) * CELL_SIZE, int(coord / width) * CELL_SIZE)
		entity.add_to_group("entities")
		add_child(entity)
		free_slots.remove_at(idx)

func reset_time(new_map: bool):
	time = 0
	frame = 0
	if current_recording: current_recording.show()
	current_recording = cursor_res.instantiate()
	current_recording.position = get_global_mouse_position()
	current_recording.hide()
	add_child(current_recording)

	if new_map:
		for entity in get_tree().get_nodes_in_group("entities"):
			entity.queue_free()
		
		generate_map_data(100, 10)

func _physics_process(delta):	
	time += delta
	if time >= cursor_lifetime:
		cursors.push_back(current_recording)
		reset_time(true)

	for cursor in cursors:
		var event = cursor.play_frame(frame, self.get_parent().get_node("%Camera2D"))
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
			entity.handle_click(event)

func _input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, event)
		handle_click(event)
	
