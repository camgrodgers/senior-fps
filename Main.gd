extends Node

var current_level = null
var in_game: bool = false

func _ready():
	load_level("res://Levels/JacobLevel2/JacobLevel2.tscn")
	$Menu.visible = true

func load_level(filename: String):
	if current_level != null:
		current_level.queue_free()
	var current_level_scn: Resource = load(filename)
	current_level = current_level_scn.instance()
	add_child(current_level)

func _on_Menu_level_selected(filename: String) -> void:
	load_level(filename)
	$Menu.visible = false
	in_game = true
