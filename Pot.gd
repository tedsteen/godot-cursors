extends Area2D

class_name Pot

const CELL_SIZE = 90
@onready var label = $Label
@onready var animated_sprite = $AnimatedSprite

@export var health: int : set = set_health

func _ready():
	set_health(randi() % 100 + 1)

func position_snapped(pos:Vector2):
	position = (pos / CELL_SIZE).floor() * CELL_SIZE

func set_health(new_health: int):
	health = new_health
	label.text = "x%d" % health

func take_damage():
	if health > 0:
		set_health(health - 1)
		if health <= 0:
			animated_sprite.play("destroy")
