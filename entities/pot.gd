extends Entity

class_name Pot

@onready var label = $Label
@onready var animated_sprite = $AnimatedSprite2D

@export var health: int : set = set_health

func _ready():
	set_health(health)

func handle_click(_event: InputEventMouse):
	if health > 0:
		health = health - 1
		if health <= 0:
			animated_sprite.play("destroy")

func set_health(p_health: int):
	health = p_health
	if label: label.text = "x%d" % health
