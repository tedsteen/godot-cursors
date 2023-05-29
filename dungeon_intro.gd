extends Control
class_name DungeonIntro
@onready var countdown_label = %CountdownLabel
var dungeon: Dungeon
@export var time = 4

func _ready():
	print_debug("Ready in intro!")

func _process(delta):
	time -= delta
	countdown_label.text = "%d" % int(time)
	if time <= 0:
		queue_free()
		get_tree().get_root().add_child(dungeon)
	pass
