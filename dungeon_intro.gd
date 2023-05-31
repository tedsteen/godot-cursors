extends Control
class_name DungeonIntro
@onready var countdown_label = %CountdownLabel
var dungeon: Dungeon
@export var time = 4

func _process(delta):
	time -= delta*2
	countdown_label.text = "%d" % int(time + 1)
	if time <= 0:
		queue_free()
		get_tree().get_root().add_child(dungeon)
	pass
