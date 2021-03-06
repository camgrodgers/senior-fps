extends VBoxContainer

signal level_selected(filename)


func _on_JacobsLevel_pressed():
	emit_signal("level_selected", "res://Levels/JacobLevel1/GameLevel.tscn")


func _on_CameronsLevel_pressed():
	emit_signal("level_selected", "res://Levels/CamLevel1/CamLevel1.tscn")


func _on_TestLevel_pressed():
	emit_signal("level_selected", "res://Levels/TestLevel/TestLevel.tscn")
