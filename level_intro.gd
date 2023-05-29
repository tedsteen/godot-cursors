extends Control
@onready var countdown_label = %CountdownLabel
var level_scene = preload("res://Level.tscn")
@export var time = 4

func _ready():
	pass # Replace with function body.

func _process(delta):
	time -= delta
	countdown_label.text = "%d" % int(time)
	if time <= 0:
		get_tree().change_scene_to_file("res://Level.tscn")
	pass
