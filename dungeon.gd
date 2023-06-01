extends Control
class_name Dungeon

const dungeon_intro_res = preload("res://dungeon_intro.tscn")
const dungeon_res = preload("res://dungeon.tscn")
const CELL_SIZE = 90

@onready var background_rect = $"."
@onready var time_rect = %TimeRect

var frame = 0
var rng_seed: int
var cursor_lifetime: int
var click_recorded = false
var current_recording: Cursor
var current_level: Level: set = set_current_level
var levels: Array[Level] = []

var cursors: Array
var last_checkpoint: int

var rng: RandomNumberGenerator

static func create(p_rng_seed: int, p_cursor_lifetime: int, p_cursors: Array = [], p_last_checkpoint = 0) -> Dungeon:
	var dungeon = dungeon_res.instantiate()
	dungeon.rng_seed = p_rng_seed
	dungeon.cursor_lifetime = p_cursor_lifetime
	dungeon.cursors = p_cursors
	dungeon.last_checkpoint = p_last_checkpoint

	return dungeon

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	
	var last_level = null
	for i in last_checkpoint + 1:
		var level = get_next_level(last_level)
		last_level = level

	current_level = levels[last_checkpoint]
	
	for cursor in cursors:
		cursor.restart(levels[cursor.spawn_level_idx])

	current_recording = Cursor.create(current_level, levels.find(current_level), get_global_mouse_position())
	cursors.append(current_recording)
	current_recording.hide()
	
	var intro: DungeonIntro = dungeon_intro_res.instantiate()
	intro.dungeon = self
	get_tree().get_root().add_child(intro)
	get_tree().get_root().remove_child(self)

func get_next_level(p_level: Level) -> Level:
	var curr_index = levels.find(p_level)
	if levels.size() <= curr_index + 1:
		var level = Level.create(rng)
		generate_map_data(level, levels.size(), 1.0, []) #TODO: solve stairs down
		level.hide()
		levels.append(level)
		add_child(level)
	return levels[curr_index + 1]

func set_current_level(new_level: Level):
	if current_level: current_level.set_active(false)
	new_level.set_active(true)
	current_level = new_level
	
func goto_next_level(cursor: Cursor, stairs_up: StairsUp):
	var next_level: Level = get_next_level(cursor.level)
	cursor.level = next_level

	if cursor == current_recording:
		current_level = next_level
	
func reset_time():
	current_recording.show()
	for cursor in cursors:
		cursor.level = null
	get_tree().get_root().add_child(Dungeon.create(rng_seed, cursor_lifetime, cursors, last_checkpoint))
	queue_free()

func _physics_process(_delta):
	#print_debug("FRAME ", frame, current_recording.left_clicked, current_recording.left_pressed)
	current_recording.left_clicked = click_recorded
	click_recorded = false
	current_recording.record_frame(frame)

	for cursor in get_tree().get_nodes_in_group("cursors"):
		cursor.play_frame(frame)
	time_rect.size.y = background_rect.size.y * (1 - frame / float(cursor_lifetime * Engine.physics_ticks_per_second))

	frame += 1
	if frame == (cursor_lifetime * Engine.physics_ticks_per_second):
		reset_time()

func _input(event):
	if event is InputEventMouse:
		current_recording.position = event.position
		if event is InputEventMouseButton:
			var left_pressed = event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed
			current_recording.left_pressed = left_pressed
			click_recorded = click_recorded || left_pressed

func generate_map_data(level: Level, level_index: int, difficulty = 1.0, static_entities: Array[Entity] = []):
	var grid_size = background_rect.size / CELL_SIZE
	var available_entities: Array[Entity] = []

	# See https://www.desmos.com/calculator/odfytj8gij
	var x0 = -32
	var y0 = 42
	var k = 2.2
	var pot_count = floor((log(level_index-x0) / log(k))*10-y0)
	for i in pot_count:
		available_entities.append(Pot.create(int(rng.randf() * level_index + 2)))

	if level_index % 4 == 0:
		if last_checkpoint <= level_index - 1:
			var gem: Gem = Gem.create()
			gem.checkpoint_reached.connect(func(): last_checkpoint = levels.find(current_level))
			available_entities.append(gem)
			#available_entities.append(Door.create(gem, func(): return level.curr_pot_health == 0))
		else:
			available_entities.append(null)

	var stairs_up: StairsUp = StairsUp.create(goto_next_level, level)
	var door_unlock_condition
	
	if level_index > 1 && rng.randi() % 3 == 0:
		var lever: Lever = Lever.create()
		available_entities.append(lever)
		door_unlock_condition = func(): return level.curr_pot_health == 0 && lever && lever.is_pulled
	else:
		door_unlock_condition = func(): return level.curr_pot_health == 0

	var unlock_all_doors = false
	if unlock_all_doors:
		door_unlock_condition = func(): return true
	available_entities.append(Door.create(stairs_up, door_unlock_condition))
	
	var free_slots: Array = range(0, grid_size.x * grid_size.y)
	
	for static_entity in static_entities:
		var x = static_entity.position.x
		var y = static_entity.position.y
		var idx = x + y * grid_size.x
		static_entity.add_to_group("entities")
		level.add_entity(static_entity)
		free_slots.remove_at(idx)

	if available_entities.size() > free_slots.size():
		push_error("Can't fit content on map.")
		return

	for entity in available_entities:
		var idx = rng.randi() % free_slots.size()
		if entity != null:
			var coord = free_slots[idx]
			entity.position = Vector2((coord % int(grid_size.x)) * CELL_SIZE, int(coord / float(grid_size.x)) * CELL_SIZE)
			entity.add_to_group("entities")

			level.add_entity(entity)
		free_slots.remove_at(idx)
