extends Entity

class_name Pot

const pot_res = preload("res://entities/pot.tscn")

@onready var label = $Label
@onready var animated_sprite = $AnimatedSprite2D
@onready var click_audio = %ClickAudio
@onready var break_audio = %BreakAudio
@export var health: int : set = set_health
var start_health: int

static func create(health: int) -> Pot:
	var pot = pot_res.instantiate()
	pot.health = health
	pot.start_health = health
	pot.add_to_group("pots")
	return pot

func _ready():
	set_health(health)

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		if health > 0:
			click_audio.play()
			health = health - 1
			if health <= 0:
				break_audio.play()
				animated_sprite.play("destroy")

func set_health(p_health: int):
	health = p_health
	if label: label.text = "x%d" % health
