extends Entity

class_name Pot

const pot_res = preload("res://entities/pot.tscn")

@onready var label = $Label
@onready var animated_sprite = $AnimatedSprite2D
@onready var click_audio = %ClickAudio
@onready var break_audio = %BreakAudio
@export var health: int : set = set_health
var start_health: int

static func create(p_health: int) -> Pot:
	var pot = pot_res.instantiate()
	pot.health = p_health
	pot.start_health = p_health
	pot.add_to_group("pots")
	return pot

func _ready():
	set_health(health)

func handle_cursors(cursors: Array[Cursor]):
	if health > 0:
		var clicks = cursors.reduce(func(acc, cursor: Cursor): return acc + 1 if cursor.left_clicked else 0, 0)
		if clicks != 0:
			click_audio.play()
			health = max(0, health - clicks)
			if health == 0:
				break_audio.play()
				animated_sprite.play("destroy")

func set_health(p_health: int):
	health = p_health
	if label: label.text = "x%d" % health
