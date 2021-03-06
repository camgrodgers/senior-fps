extends Node

var current_level = null
var in_game: bool = false

func _ready():
	_load_screensaver()

func _load_screensaver():
	_load_level("res://Levels/JacobLevel2/JacobLevel2.tscn")
	$Menu.visible = true
	in_game = false

func _load_level(filename: String):
	if current_level != null:
		current_level.queue_free()
	var current_level_scn: Resource = load(filename)
	current_level = current_level_scn.instance()
	$Level.add_child(current_level)

func _on_Menu_level_selected(filename: String) -> void:
	_load_level(filename)
	$Menu.visible = false
	in_game = true


func _on_Menu_restart_level():
	pass


func _on_Menu_quit():
	if in_game:
		in_game = false
		_load_screensaver()
	else:
		get_tree().quit()
