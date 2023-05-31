extends Entity
class_name Gem

const gem_res = preload("res://entities/gem.tscn")

@onready var checkpoint_audio = %CheckpointAudio
@onready var destroy_animation = %Animation

static func create() -> Gem:
	var gem: Gem = gem_res.instantiate()
	gem.add_to_group("gems")
	return gem

func handle_cursors(cursors: Array[Cursor]):
	if cursors.any(func(cursor): return cursor.left_clicked):
		checkpoint_audio.play()
		disable()
		destroy_animation.play("destroy")
		z_index = 4096
		# TODO: Await multiple signals..
		#await checkpoint_audio.finished
		await destroy_animation.animation_finished
		
		#queue_free() # TODO: This would be nicer, but we keep a reference to all entities in level
		visible = false
