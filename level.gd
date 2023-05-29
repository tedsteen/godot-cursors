extends Node2D
class_name Level

var width: int
var height: int
const level_res = preload("res://Level.tscn")
const pot_res = preload("res://entities/pot.tscn")
const door_res = preload("res://entities/door.tscn")
const lever_res = preload("res://entities/lever.tscn")
const gem_res = preload("res://entities/gem.tscn")
var stairs_up_res = preload("res://entities/stairs_up.tscn")

var rng: RandomNumberGenerator

@export var rng_seed = 1

const CELL_SIZE = 90
static func create(rng_seed: int, width: int, height: int):
	var level: Level = level_res.instantiate()
	level.rng_seed = rng_seed
	level.width = width
	level.height = height
	return level
	
func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	generate_map_data(2, 2)

func put_behind_door(lever: Lever, entity: Entity) -> Door:
	var door: Door = door_res.instantiate()
	door.lever = lever
	door.hidden_entity = entity
	return door

func generate_map_data(difficulty: int, amount: int):	
	var available_entities: Array[Entity] = []

	for i in range(0, amount):
		var pot: Pot = pot_res.instantiate()
		pot.health = rng.randi() % difficulty + 1
		available_entities.append(pot)
	
	var lever: Lever = lever_res.instantiate()
	available_entities.append(lever)
	for i in range(0, 3):
		var gem: Gem = gem_res.instantiate()
		available_entities.append(gem)
		#available_entities.append(put_behind_door(lever, gem))
	
	var stairs_up: StairsUp = stairs_up_res.instantiate()
	stairs_up.next_level_rng_seed = rng.randi()
	
	#available_entities.append(stairs_up)
	available_entities.append(put_behind_door(lever, stairs_up))

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

