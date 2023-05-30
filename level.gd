extends Node2D
class_name Level

const level_res = preload("res://Level.tscn")

var width: int
var height: int
var difficulty = 0
var rng: RandomNumberGenerator

var total_pot_health: int
var curr_pot_health: int

const CELL_SIZE = 90
static func create(p_rng: RandomNumberGenerator, p_width: int, p_height: int, p_difficulty = 0) -> Level:
	print_debug("create level ", p_difficulty)
	var level: Level = level_res.instantiate()
	level.rng = p_rng
	level.width = p_width
	level.height = p_height
	level.difficulty = p_difficulty
	return level
	
func _ready():
	generate_map_data()
	total_pot_health = count_pot_health()

func set_active(p_active: bool):
	self.visible = p_active
	#TODO: Mute everything on this level if !active

func count_pot_health() -> int:
	var total_pot_health = 0
	for pot in get_nodes_in_group("pots"):
		total_pot_health += pot.health
	return total_pot_health

func _physics_process(_delta):
	curr_pot_health = count_pot_health()
	
func get_nodes_in_group(group: StringName) -> Array[Node]:
	return get_tree().get_nodes_in_group(group).filter(func(node: Node):
		return node.get_parent() == self || node.get_parent().get_parent().get_parent() == self
	)

func has_entity(entity: Entity) -> bool:
	return get_nodes_in_group("entities").any(func(node): return node == entity)
	
func generate_map_data():
	
	var available_entities: Array[Entity] = []

	for i in range(0, 1 + int(difficulty*0.5)):
		available_entities.append(Pot.create(rng.randf() * difficulty + 1))

	var gem: Gem = Gem.create()
	available_entities.append(gem)
	#available_entities.append(Door.create(gem, pots_cleared, lever))

	var stairs_up: StairsUp = StairsUp.create()
	if difficulty > 1 && rng.randi() % 3 == 0:
		var lever: Lever = Lever.create()
		available_entities.append(lever)
		available_entities.append(Door.create(stairs_up, func(): return curr_pot_health == 0 && lever.is_pulled))
	else:
		available_entities.append(Door.create(stairs_up, func(): return curr_pot_health == 0))

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

