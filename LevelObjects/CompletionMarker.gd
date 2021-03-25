tool
extends SnapToTerrain

onready var signals = get_node("/root/Signals")
export(bool) var end_level = true

func _on_Area_body_entered(body):
	if body is Player:
		signals.emit_signal("level_completed", end_level)
