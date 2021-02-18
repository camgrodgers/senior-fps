extends Node

var current_level: Navigation = null

func load_level(filename: String):
	if current_level != null:
		current_level.queue_free()
	var current_level_scn: Resource = load(filename)
	current_level = current_level_scn.instance()
	add_child(current_level)
	$Menu.visible = false

func _on_Button3_pressed():
	load_level("res://Levels/TestLevel/TestLevel.tscn")

func _on_Button_pressed():
	load_level("res://Levels/JacobLevel1/GameLevel.tscn")

func _on_Button2_pressed():
	load_level("res://Levels/CamLevel1/CamLevel1.tscn")
