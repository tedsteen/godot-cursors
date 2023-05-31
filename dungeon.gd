extends Node2D
class_name Dungeon

const dungeon_intro_res = preload("res://dungeon_intro.tscn")
const dungeon_res = preload("res://dungeon.tscn")

@export var rng_seed = 0
@export var cursor_lifetime = 15

@onready var background_rect = %BackgroundRect
@onready var time_rect = %TimeRect
@onready var progress_rect = %ProgressRect
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var dss: = get_world_2d().direct_space_state

var frame
var current_recording: Cursor
var levels: Array[Level] = []
var rng: RandomNumberGenerator

var point_params: = PhysicsPointQueryParameters2D.new()

static func create(p_rng_seed: int) -> Dungeon:
	var dungeon = dungeon_res.instantiate()
	dungeon.rng_seed = p_rng_seed
	return dungeon

func _ready():
	point_params.collide_with_areas = true
	#point_params.collision_mask = 2
	reset_time()

func get_next_level(p_level: Level) -> Level:
	var curr_index = levels.find(p_level)
	if levels.size() <= curr_index + 1:
		var level = Level.create(rng, int(background_rect.size.x / Level.CELL_SIZE), int(background_rect.size.y / Level.CELL_SIZE), curr_index + 1)
		level.hide()
		levels.append(level)
		add_child(level)
	return levels[curr_index + 1]

func goto_next_level(cursor: Cursor):
	var next_level: Level = get_next_level(cursor.level)
	
	if cursor == current_recording:
		cursor.level.set_active(false)
		next_level.set_active(true)
	
	cursor.level = next_level

func reset_time():
	frame = 0
	for level in levels:
		level.queue_free()
	levels = []
	
	if current_recording:
		current_recording.show()

	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed

	var level1 = Level.create(rng, int(background_rect.size.x / Level.CELL_SIZE), int(background_rect.size.y / Level.CELL_SIZE))
	levels.append(level1)
	add_child(level1)

	for cursor in get_tree().get_nodes_in_group("cursors"):
		cursor.level = level1

	current_recording = Cursor.create(level1, get_global_mouse_position(), goto_next_level)
	level1.show()
	current_recording.hide()

	var intro: DungeonIntro = dungeon_intro_res.instantiate()
	intro.time = 3
	intro.dungeon = self
	get_tree().get_root().add_child.call_deferred(intro)
	get_tree().get_root().remove_child(self)

var last_mouse_event: InputEventMouse

func _physics_process(delta):
	if frame == (cursor_lifetime * Engine.physics_ticks_per_second):
		reset_time()
		return		

	if last_mouse_event:
		current_recording.record_frame(frame, last_mouse_event)
		last_mouse_event = null

	for level in levels:
		var cursors_per_entity = {}
		for entity in level.get_nodes_in_group("entities"):
			var cs: Array[Cursor] = []
			cursors_per_entity[entity] = cs

		for cursor in level.get_nodes_in_group("cursors"):
			cursor.play_frame(frame)
			point_params.position = cursor.position * view_to_world
			var hits = dss.intersect_point(point_params)
			for hit in hits:
				var entity = hit.collider
				if level.has_entity(entity):
					cursors_per_entity[entity].append(cursor)
		
		for entity in cursors_per_entity:
			entity.handle_cursors(cursors_per_entity[entity])

	time_rect.size.y = background_rect.size.y * (1 - frame / float(cursor_lifetime * Engine.physics_ticks_per_second))
	var total_pot_health = current_recording.level.total_pot_health
	var remaining_pot_health = current_recording.level.curr_pot_health

	progress_rect.size.y = 0 if total_pot_health == 0 else background_rect.size.y * (1 - (total_pot_health - remaining_pot_health) / float(total_pot_health))
	frame += 1

func _input(event):
	if event is InputEventMouse:
		# Prioritise clicks
		if not last_mouse_event is InputEventMouseButton:
			last_mouse_event = event
		

