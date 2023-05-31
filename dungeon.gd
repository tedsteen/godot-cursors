extends Control
class_name Dungeon

const dungeon_intro_res = preload("res://dungeon_intro.tscn")
const dungeon_res = preload("res://dungeon.tscn")
const CELL_SIZE = 90

@onready var background_rect = $"."
@onready var time_rect = %TimeRect
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var dss: = get_world_2d().direct_space_state

var frame = 0
var rng_seed: int
var cursor_lifetime: int
var current_recording: Cursor
var current_level: Level: set = set_current_level
var levels: Array[Level] = []
var cursors: Array
var rng: RandomNumberGenerator
var last_mouse_event: InputEventMouse
var point_params: = PhysicsPointQueryParameters2D.new()

static func create(p_rng_seed: int, p_cursor_lifetime: int, p_cursors: Array = []) -> Dungeon:
	var dungeon = dungeon_res.instantiate()
	dungeon.rng_seed = p_rng_seed
	dungeon.cursor_lifetime = p_cursor_lifetime
	dungeon.cursors = p_cursors
	return dungeon

func _ready():

	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	point_params.collide_with_areas = true

	var level1 = Level.create(rng)
	generate_map_data(level1, 0)
	levels.append(level1)
	add_child(level1)
	current_level = level1
	for cursor in cursors:
		cursor.restart(level1)

	var intro: DungeonIntro = dungeon_intro_res.instantiate()
	intro.dungeon = self
	get_tree().get_root().add_child(intro)
	get_tree().get_root().remove_child(self)

func get_next_level(p_level: Level, p_stairs_up: StairsUp) -> Level:
	var curr_index = levels.find(p_level)
	if levels.size() <= curr_index + 1:
		var level = Level.create(rng)
		generate_map_data(level, curr_index + 1, [p_stairs_up.connected_stairs])
		level.hide()
		levels.append(level)
		add_child(level)
	return levels[curr_index + 1]

func set_current_level(new_level: Level):
	if current_level: current_level.set_active(false)
	new_level.set_active(true)
	current_level = new_level
	
func goto_next_level(cursor: Cursor, stairs_up: StairsUp):
	var next_level: Level = get_next_level(cursor.level, stairs_up)	
	cursor.level = next_level

	if cursor == current_recording:
		current_level = next_level
	
func reset_time():
	if current_recording: current_recording.show()
	for cursor in cursors:
		cursor.level = null
	get_tree().get_root().add_child(Dungeon.create(rng_seed, cursor_lifetime, cursors))
	queue_free()

func _physics_process(_delta):
	if last_mouse_event:
		if !current_recording:
			current_recording = Cursor.create(levels[0], get_global_mouse_position())
			cursors.append(current_recording)
			current_recording.hide()
		current_recording.record_frame(frame, last_mouse_event)
		last_mouse_event = null

	for level in levels:
		var cursors_per_entity = {}
		for entity in level.get_nodes_in_group("entities"):
			var cs: Array[Cursor] = []
			cursors_per_entity[entity] = cs

		for cursor in cursors:
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

	frame += 1

	if frame == (cursor_lifetime * Engine.physics_ticks_per_second):
		reset_time()

func _input(event):
	if event is InputEventMouse:
		# Prioritise clicks
		if not last_mouse_event is InputEventMouseButton:
			last_mouse_event = event

func generate_map_data(level: Level, difficulty: int, static_entities: Array[Entity] = []):
	var size = background_rect.size / CELL_SIZE
	var available_entities: Array[Entity] = []

	for i in range(0, 1 + int(difficulty*0.5)):
		available_entities.append(Pot.create(int(rng.randf() * difficulty + 1)))

	var gem: Gem = Gem.create()
	available_entities.append(gem)
	#available_entities.append(Door.create(gem, pots_cleared, lever))

	var stairs_up: StairsUp = StairsUp.create(goto_next_level, level)
	var door_unlock_condition
	
	if difficulty > 1 && rng.randi() % 3 == 0:
		var lever: Lever = Lever.create()
		available_entities.append(lever)
		door_unlock_condition = func(): return level.curr_pot_health == 0 && lever && lever.is_pulled
	else:
		door_unlock_condition = func(): return level.curr_pot_health == 0

	available_entities.append(Door.create(stairs_up, door_unlock_condition))
	
	var free_slots: Array = range(0, size.x * size.y)
	
	for static_entity in static_entities:
		var x = static_entity.position.x
		var y = static_entity.position.y
		var idx = x + y * size.x
		static_entity.add_to_group("entities")
		level.add_child(static_entity)
		free_slots.remove_at(idx)
		
	if available_entities.size() > free_slots.size():
		push_error("Can't fit content on map.")
		return

	for entity in available_entities:
		var idx = rng.randi() % free_slots.size()
		var coord = free_slots[idx]
		entity.position = Vector2((coord % int(size.x)) * CELL_SIZE, int(coord / float(size.x)) * CELL_SIZE)
		entity.add_to_group("entities")

		level.add_child(entity)
		free_slots.remove_at(idx)
