extends Entity
class_name Gem

@onready var checkpoint_audio = %CheckpointAudio
@onready var destroy_animation = %Animation
		
func _ready():
	add_to_group("gems")

func handle_mouse(event: InputEventMouse):
	if event is InputEventMouseButton && event.button_index == 1 && event.pressed:
		checkpoint_audio.play()
		disable()
		destroy_animation.play("destroy")
		z_index = 4096
		# TODO: Await multiple signals..
		#await checkpoint_audio.finished
		await destroy_animation.animation_finished
		
		queue_free()
