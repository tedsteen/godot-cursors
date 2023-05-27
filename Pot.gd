extends Node2D

class_name Pot

@onready var label = $Label
@onready var animated_sprite = $AnimatedSprite

@export var health: int : set = set_health

func take_damage():
	if health > 0:
		health = health - 1
		if health <= 0:
			animated_sprite.play("destroy")

func set_health(p_health: int):
	health = p_health
	label.text = "x%d" % health
