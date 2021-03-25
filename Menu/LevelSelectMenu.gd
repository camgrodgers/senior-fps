extends VBoxContainer

onready var signals = get_node("/root/Signals")

func _on_JacobsLevel_pressed():
	signals.emit_signal("level_selected", "res://Levels/JacobLevel1/GameLevel.tscn")


func _on_CameronsLevel_pressed():
	signals.emit_signal("level_selected", "res://Levels/CamLevel1/CamLevel1.tscn")


func _on_TestLevel_pressed():
	signals.emit_signal("level_selected", "res://Levels/TestLevel/TestLevel.tscn")


func _on_CanyonInfiltration_pressed():
	signals.emit_signal("level_selected", "res://Levels/CanyonInfiltration/CanyonInfiltration.tscn")
