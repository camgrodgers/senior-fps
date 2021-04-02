tool
extends SnapToTerrain

onready var signals = get_node("/root/Signals")

func _process(delta):
	if Engine.editor_hint:
		pass
	else:
		_game_process(delta)

export(String, MULTILINE) var text = ""


func _game_process(delta: float) -> void:
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("spin")

func _on_Area_area_entered(area):
	$AnimationPlayer.playback_speed = 5
	signals.emit_signal("popup_message", text)

func _on_Area_area_exited(area):
	$AnimationPlayer.playback_speed = 2
	signals.emit_signal("hide_popup_message")
