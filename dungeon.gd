extends Node2D
class_name Dungeon

@export var rng_seed = 0
@export var cursor_lifetime = 5

@onready var background_rect = %BackgroundRect
@onready var time_rect = %TimeRect
@onready var progress_rect = %ProgressRect
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var dss: = get_world_2d().direct_space_state

var time
var frame
var rng: RandomNumberGenerator
var current_recording: Cursor
var cursors: Array[Cursor]

var point_params: = PhysicsPointQueryParameters2D.new()

var levels: Array[Level] = []

func _ready():	
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	point_params.collide_with_areas = true
	#point_params.collision_mask = 2
	cursors = []
	var level1 = Level.create(0, int(background_rect.size.x / Level.CELL_SIZE), int(background_rect.size.y / Level.CELL_SIZE))
	levels.append(level1)
	add_child(level1)
	reset_time()

#func set_curr_level(p_level: Level):
#	if curr_level: curr_level.hide()
#	curr_level = p_level
#	add_child(p_level)

func get_next_level(p_level: Level) -> Level:
	var curr_index = levels.find(p_level)
	if levels.size() <= curr_index +1:
		print_debug("Need a new level")	
	return p_level

func goto_next_level(cursor: Cursor):
	print_debug("TODO: Goto next level!! ", cursor)

func reset_time():
	time = 0
	frame = 0
	if current_recording: current_recording.show()
	current_recording = Cursor.create(levels[0], get_global_mouse_position(), goto_next_level)
	current_recording.hide()
	cursors.append(current_recording)

	#if new_map:
	#	for entity in get_tree().get_nodes_in_group("entities"):
	#		entity.queue_free()
	#	
	#	generate_map_data(5, 1)
var last_mouse_event: InputEventMouse

func _physics_process(delta):
	time += delta
	if time >= cursor_lifetime:
		reset_time()
		return

	if last_mouse_event:
		current_recording.record_frame(frame, last_mouse_event)
		last_mouse_event = null

	var cursors_per_entity = {}
	for entity in get_tree().get_nodes_in_group("entities"):
		var cs: Array[Cursor] = []
		cursors_per_entity[entity] = cs
	
	for cursor in cursors:
		cursor.play_frame(frame)
		point_params.position = cursor.position * view_to_world
		var hits = dss.intersect_point(point_params)
		for hit in hits:
			var entity = hit.collider
			cursors_per_entity[entity].append(cursor)
	
	for entity in cursors_per_entity:
		entity.handle_cursors(cursors_per_entity[entity])

	time_rect.size.y = background_rect.size.y * (1 - time / cursor_lifetime)
	var total_pot_health = 0
	var remaining_pot_health = 0
	for pot in get_tree().get_nodes_in_group("pots"):
		remaining_pot_health += pot.health
		total_pot_health += pot.start_health

	progress_rect.size.y = 0 if total_pot_health == 0 else background_rect.size.y * (1 - (total_pot_health - remaining_pot_health) / float(total_pot_health))
	frame += 1

func _input(event):
	if event is InputEventMouse:
		# Prioritise clicks
		if not last_mouse_event is InputEventMouseButton:
			last_mouse_event = event
		

