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
var current_recording: Cursor
var cursors: Array[Cursor]

var point_params: = PhysicsPointQueryParameters2D.new()

var curr_level: Level : set = set_curr_level

func _ready():
	reset_time()
	point_params.collide_with_areas = true
	#point_params.collision_mask = 2
	cursors = []

	curr_level = Level.create(rng_seed, int(background_rect.size.x / Level.CELL_SIZE), int(background_rect.size.y / Level.CELL_SIZE))

func set_curr_level(p_level: Level):
	if curr_level: curr_level.hide()
	curr_level = p_level
	add_child(p_level)
	
func reset_time():
	time = 0
	frame = 0
	if current_recording: current_recording.show()
	current_recording = Cursor.create(get_global_mouse_position(), false)
	add_child(current_recording)

	#if new_map:
	#	for entity in get_tree().get_nodes_in_group("entities"):
	#		entity.queue_free()
	#	
	#	generate_map_data(5, 1)

func _physics_process(delta):
	time += delta
	if time >= cursor_lifetime:
		cursors.push_back(current_recording)
		reset_time()
		return

	for cursor in cursors:
		var event = cursor.play_frame(frame)
		if event: handle_mouse(event, false)

	time_rect.size.y = background_rect.size.y * (1 - time / cursor_lifetime)
	var total_pot_health = 0
	var remaining_pot_health = 0
	for pot in get_tree().get_nodes_in_group("pots"):
		remaining_pot_health += pot.health
		total_pot_health += pot.start_health

	progress_rect.size.y = 0 if total_pot_health == 0 else background_rect.size.y * (1 - (total_pot_health - remaining_pot_health) / float(total_pot_health))
	frame += 1

func handle_mouse(event: InputEventMouse, real_mouse: bool):
	point_params.position = event.position * view_to_world
	var hits = dss.intersect_point(point_params)

	for hit in hits:
		var entity = hit.collider
		entity.handle_mouse(event)

func _input(event):
	if event is InputEventMouse:
		current_recording.record_frame(frame, event)
		handle_mouse(event, true)
