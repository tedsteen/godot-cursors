extends Node2D
class_name Level

const level_res = preload("res://Level.tscn")

var rng: RandomNumberGenerator

var total_pot_health: int
var curr_pot_health: int

static func create(p_rng: RandomNumberGenerator) -> Level:
	var level: Level = level_res.instantiate()
	level.rng = p_rng
	return level
	
func _ready():
	total_pot_health = count_pot_health()

func set_active(p_active: bool):
	self.visible = p_active
	#TODO: Mute everything on this level if !active

func count_pot_health() -> int:
	var total = 0
	for pot in get_nodes_in_group("pots"):
		total += pot.health
	return total

func _physics_process(_delta):
	curr_pot_health = count_pot_health()
	
func get_nodes_in_group(group: StringName) -> Array[Node]:
	return get_tree().get_nodes_in_group(group).filter(func(node: Node):
		return node.get_parent() == self || node.get_parent().get_parent().get_parent() == self
	)

func has_entity(entity: Entity) -> bool:
	return get_nodes_in_group("entities").any(func(node): return node == entity)
	

