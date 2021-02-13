extends Node

var current_level: Navigation = null

func _ready():
	var current_level_scn: Resource = load("res://Levels/TestLevel.tscn")
	current_level = current_level_scn.instance()
	add_child(current_level)
	$Menu.visible = false
