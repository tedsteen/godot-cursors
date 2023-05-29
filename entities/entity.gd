extends Area2D
class_name Entity
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func handle_mouse(_event: InputEventMouse):
	push_warning("Unhandled mouse on %s" % self)
