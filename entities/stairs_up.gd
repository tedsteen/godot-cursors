extends Entity
class_name StairsUp

@onready var next_level_audio = %NextLevelAudio
@export var next_level_rng_seed = randi()

func _ready():
	add_to_group("up_stairs")

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		
		next_level_audio.play()
