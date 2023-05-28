extends Entity
class_name Gem

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		queue_free()
