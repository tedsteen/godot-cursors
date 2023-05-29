extends Entity
class_name StairsUp

const stairs_up_res = preload("res://entities/stairs_up.tscn")

@onready var next_level_audio = %NextLevelAudio
@export var next_level_rng_seed = randi()

static func create(next_level_rng_seed: int) -> StairsUp:
	var stairs_up: StairsUp = stairs_up_res.instantiate()
	stairs_up.next_level_rng_seed = next_level_rng_seed
	stairs_up.add_to_group("up_stairs")
	return stairs_up

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		
		next_level_audio.play()
