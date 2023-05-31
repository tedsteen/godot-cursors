extends Control
class_name Level

@onready var background_rect = $"."
@onready var progress_rect = %ProgressRect
@onready var view_to_world = self.get_canvas_transform().affine_inverse()
@onready var dss: = get_world_2d().direct_space_state

const level_res = preload("res://Level.tscn")

var point_params: = PhysicsPointQueryParameters2D.new()
var rng: RandomNumberGenerator
var total_pot_health: int
var curr_pot_health: int
var entities: Array[Entity] = []
var cursors: Array[Cursor] = []

static func create(p_rng: RandomNumberGenerator) -> Level:
	var level: Level = level_res.instantiate()
	level.rng = p_rng
	return level
	
func _ready():
	total_pot_health = count_pot_health()
	point_params.collide_with_areas = true

func set_active(p_active: bool):
	self.visible = p_active
	#TODO: Mute everything on this level if !active

func count_pot_health() -> int:	
	return entities.reduce(func(acc, entity: Entity): return acc + entity.health if entity is Pot else acc, 0)

func _physics_process(_delta):		
	var cursors_per_entity = {}

	for entity in entities:
		#print_debug("entities in ", entity, self)
		var cs: Array[Cursor] = []
		cursors_per_entity[entity] = cs

	for cursor in cursors:
		#print_debug("cursor in ", cursor, self)
		point_params.position = cursor.position * view_to_world
		var hits = dss.intersect_point(point_params)
		for hit in hits:
			var entity = hit.collider
			if entities.has(entity): #if entity is on the level
				cursors_per_entity[entity].append(cursor)
	
	for entity in cursors_per_entity:
		entity.handle_cursors(cursors_per_entity[entity])

	curr_pot_health = count_pot_health()
	progress_rect.size.y = 0 if total_pot_health == 0 else background_rect.size.y * (1 - (total_pot_health - curr_pot_health) / float(total_pot_health))

func add_entity(entity: Entity):
	entities.append(entity)
	add_child(entity)
