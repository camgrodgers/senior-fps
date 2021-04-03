extends VBoxContainer

onready var signals = get_node("/root/Signals")

func _ready():
	number_levels()

func number_levels():
	var children := get_children()
	var i: int = 0
	for c in children:
		if c is LevelSelectBox:
			c.level_order_number = i
			c._update_text()
			i = i + 1

