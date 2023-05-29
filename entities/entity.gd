extends Area2D
class_name Entity
@onready var sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func handle_cursors(cursors: Array[Cursor]):
	push_warning("Unhandled cursors on %s" % self)

func disable():
	collision_shape.disabled = true

func enable():
	collision_shape.disabled = false
