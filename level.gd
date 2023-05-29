extends Node2D
var cursor_res = preload("res://cursor.tscn")
var pot_res = preload("res://entities/pot.tscn")
var door_res = preload("res://entities/door.tscn")
var lever_res = preload("res://entities/lever.tscn")
var gem_res = preload("res://entities/gem.tscn")
var stairs_up_res = preload("res://entities/stairs_up.tscn")

var rng: RandomNumberGenerator

@onready var background_rect = %BackgroundRect
@onready var time_rect = %TimeRect
@onready var progress_rect = %ProgressRect
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

	var pots: Array[Pot] = []
	for i in range(0, amount):
		var pot: Pot = pot_res.instantiate()
		pot.add_to_group("pots")
		pot.health = rng.randi() % difficulty + 1
		available_entities.append(pot)
		pots.append(pot)

	var gem: Gem = gem_res.instantiate()
	gem.add_to_group("gems")
	available_entities.append(gem)

	var stairs_up: StairsUp = stairs_up_res.instantiate()
	stairs_up.add_to_group("up_stairs")
	#available_entities.append(stairs_up)

	var door: Door = door_res.instantiate()
	door.add_to_group("doors")
	door.pots = pots
	door.hidden_entity = stairs_up
	available_entities.append(door)
	
	var lever = lever_res.instantiate()
	lever.door = door
	lever.add_to_group("levers")
	available_entities.append(lever)
	
	var width = int(background_rect.size.x / CELL_SIZE)
	var height = int(background_rect.size.y / CELL_SIZE)

	if available_entities.size() > width * height:
		push_error("Can't fit content on map.")
		return
	
	var free_slots: Array = range(0, width * height)
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
		
		generate_map_data(5, 1)

func _physics_process(delta):
	time += delta
	if time >= cursor_lifetime:
		cursors.push_back(current_recording)
		reset_time(false)
		return

	for cursor in cursors:
		var event = cursor.play_frame(frame)
		if event: handle_mouse(event)
	
	
	time_rect.size.y = background_rect.size.y * (1 - time / cursor_lifetime)
	var total_pot_health = 0
	var remaining_pot_health = 0
	for pot in get_tree().get_nodes_in_group("pots"):
		remaining_pot_health += pot.health
		total_pot_health += pot.start_health

	progress_rect.size.y = 0 if total_pot_health == 0 else background_rect.size.y * (1 - (total_pot_health - remaining_pot_health) / float(total_pot_health))
	frame += 1

func handle_mouse(event: InputEventMouse):
	point_params.position = event.position * view_to_world
	var hits = dss.intersect_point(point_params)

	for hit in hits:
		var entity = hit.collider
		entity.handle_mouse(event)

func _input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, event)
		handle_mouse(event)
	
