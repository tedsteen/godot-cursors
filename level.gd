extends Node2D
class_name Level

const level_res = preload("res://Level.tscn")

var width: int
var height: int

var rng: RandomNumberGenerator

@export var rng_seed = 1

const CELL_SIZE = 90
static func create(rng_seed: int, width: int, height: int) -> Level:
	var level: Level = level_res.instantiate()
	level.rng_seed = rng_seed
	level.width = width
	level.height = height
	return level
	
func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	generate_map_data(2, 2)

func generate_map_data(difficulty: int, amount: int):	
	var available_entities: Array[Entity] = []

	for i in range(0, amount):
		available_entities.append(Pot.create(rng.randi() % difficulty + 1))
	
	var lever: Lever = Lever.create()
	available_entities.append(lever)
	for i in range(0, 3):
		var gem: Gem = Gem.create()
		available_entities.append(gem)
		#available_entities.append(Door.create(lever, gem))
	
	var stairs_up: StairsUp = StairsUp.create(rng.randi())
	
	#available_entities.append(stairs_up)
	available_entities.append(Door.create(lever, stairs_up))

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

