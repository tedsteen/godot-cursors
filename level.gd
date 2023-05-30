extends Node2D
class_name Level

const level_res = preload("res://Level.tscn")

var width: int
var height: int
var rng: RandomNumberGenerator

var total_pot_health: int
var curr_pot_health: int : set = set_curr_pot_health

@export var rng_seed = 1

signal pots_cleared(is_cleared: bool)

const CELL_SIZE = 90
static func create(p_rng_seed: int, p_width: int, p_height: int) -> Level:
	var level: Level = level_res.instantiate()
	level.rng_seed = p_rng_seed
	level.width = p_width
	level.height = p_height
	return level
	
func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = rng_seed
	generate_map_data(2, 2)
	total_pot_health = count_pot_health()

func count_pot_health() -> int:
	var total_pot_health = 0
	for pot in get_nodes_in_group("pots"):
		total_pot_health += pot.health
	return total_pot_health

func set_curr_pot_health(new_health: int):
	if curr_pot_health != new_health:
		curr_pot_health = new_health
		if curr_pot_health == 0: pots_cleared.emit(true)

func _physics_process(_delta):
	curr_pot_health = count_pot_health()
	
func get_nodes_in_group(group: StringName) -> Array[Node]:
	return get_tree().get_nodes_in_group(group).filter(func(node: Node):
		return node.get_parent() == self || node.get_parent().get_parent().get_parent() == self
	)

func has_entity(entity: Entity) -> bool:
	return get_nodes_in_group("entities").any(func(node): return node == entity)
	
func generate_map_data(difficulty: int, amount: int):	
	var available_entities: Array[Entity] = []

	for i in range(0, amount):
		available_entities.append(Pot.create(rng.randi() % difficulty + 1))
	
	#var lever: Lever = Lever.create()
	#available_entities.append(lever)
	for i in range(0, 1):
		var gem: Gem = Gem.create()
		available_entities.append(gem)
		#available_entities.append(Door.create(gem, pots_cleared, lever))
	
	var stairs_up: StairsUp = StairsUp.create()
	#available_entities.append(stairs_up)
	available_entities.append(Door.create(stairs_up, pots_cleared))

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

