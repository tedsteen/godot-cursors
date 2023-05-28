extends Entity

class_name Lever
var door: Door : set = set_door
var down_btn_counter = 0
var open = false : set = set_open

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.pressed:
			down_btn_counter += 1
		else:
			down_btn_counter -= 1
		open = down_btn_counter > 0

func set_open(p_open: bool):
	if open != p_open:
		open = p_open
		if open:
			$AnimatedSprite2D.play("default")
		else:
			$AnimatedSprite2D.play_backwards("default")
		door.set_locked(!open)

func set_door(p_door: Door):
	door = p_door
	door.set_locked(true)
