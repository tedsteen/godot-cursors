extends Entity
class_name Door

@onready var open_audio = %OpenAudio
@onready var close_audio = %CloseAudio
@onready var closed_click_audio = %ClosedClickAudio
@onready var hidden_entity_container = %HiddenEntityContainer

var open = false: set = set_open
var available = false : set = set_available
var locked = false : set = set_locked
var hidden_entity : set = set_hidden_entity, get = get_hidden_entity

var pots: Array[Pot] = []

func _ready():
	var entity = get_hidden_entity()
	if entity:
		hidden_entity_container.add_child(entity)
		entity.disable()

func _physics_process(delta):
	var total_pot_health = 0
	for pot in pots:
		total_pot_health += pot.health
	available = total_pot_health == 0
	
func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		if !open: closed_click_audio.play()

func set_locked(p_locked: bool):
	if locked != p_locked:
		locked = p_locked
		set_open(available && !locked)

func set_available(p_available: bool):
	if available != p_available:
		available = p_available
		set_open(available && !locked)

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
