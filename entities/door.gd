extends Entity
class_name Door

const door_res = preload("res://entities/door.tscn")

@onready var open_audio = %OpenAudio
@onready var close_audio = %CloseAudio
@onready var closed_click_audio = %ClosedClickAudio
@onready var hidden_entity_container = %HiddenEntityContainer

var open = false: set = set_open
var unlock_condition: Callable
var hidden_entity : set = set_hidden_entity, get = get_hidden_entity

static func create(p_hidden_entity: Entity, p_unlock_condition: Callable) -> Door:
	var door: Door = door_res.instantiate()
	door.unlock_condition = p_unlock_condition
	door.hidden_entity = p_hidden_entity
	p_hidden_entity.add_to_group("entities")
	door.add_to_group("doors")
	return door

func _ready():
	var entity = get_hidden_entity()
	if entity:
		hidden_entity_container.add_child(entity)
		entity.disable()

func _physics_process(_delta):
	open = unlock_condition.call()

func handle_cursors(cursors: Array[Cursor]):
	if !open && cursors.any(func(cursor: Cursor): return cursor.left_clicked):
		closed_click_audio.play()

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
