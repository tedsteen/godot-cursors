extends Entity
class_name Door

const door_res = preload("res://entities/door.tscn")

@onready var open_audio = %OpenAudio
@onready var close_audio = %CloseAudio
@onready var closed_click_audio = %ClosedClickAudio
@onready var hidden_entity_container = %HiddenEntityContainer

var open = false: set = set_open
var lock_signal: Signal
#var available = false : set = set_available
#var unlocked = true : set = set_unlocked
var hidden_entity : set = set_hidden_entity, get = get_hidden_entity
#var lever: Lever

static func create(p_hidden_entity: Entity, p_lock_signal: Signal, p_lever: Lever = null) -> Door:
	var door: Door = door_res.instantiate()
	door.lock_signal = p_lock_signal
	#door.lever = p_lever
	door.hidden_entity = p_hidden_entity
	p_hidden_entity.add_to_group("entities")
	door.add_to_group("doors")
	return door
	
func _ready():
	var entity = get_hidden_entity()
	if entity:
		hidden_entity_container.add_child(entity)
		entity.disable()
	
	lock_signal.connect(set_open)

#func _physics_process(_delta):
#	var total_pot_health = 0
#	for pot in get_tree().get_nodes_in_group("pots"):
#		total_pot_health += pot.health
#	available = total_pot_health == 0
	
func handle_cursors(cursors: Array[Cursor]):
	if !open && cursors.any(func(cursor: Cursor): return cursor.left_clicked):
		closed_click_audio.play()

#func set_unlocked(p_unlocked: bool):
#	if unlocked != p_unlocked:
#		unlocked = p_unlocked
#		open = available && unlocked

#func set_available(p_available: bool):
#	if available != p_available:
#		available = p_available
#		open = available && unlocked

func set_open(p_open: bool):
	if open != p_open:
		open = p_open
		if open:
			open_audio.play()
			sprite.play("default")
			var entity = get_hidden_entity()
			if entity: entity.enable()
		else:
			sprite.play_backwards("default")
			var entity = get_hidden_entity()
			if entity: entity.disable()
			await sprite.animation_finished
			close_audio.play()

func set_hidden_entity(entity: Entity):
	hidden_entity = weakref(entity)

func get_hidden_entity() -> Entity:
	return hidden_entity.get_ref()
