extends Node

var current_level = null
var in_game: bool = false
onready var signals = get_node("/root/Signals")

func _ready():
	_load_screensaver()
	signals.connect("level_selected", self, "_on_level_selected")
	signals.connect("restart_level", self, "_on_restart_level")
	signals.connect("quit", self, "_on_quit")
	signals.connect("level_completed", self, "_on_level_completed")
	

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

func _on_level_selected(filename: String) -> void:
	_load_level(filename)
	$Menu.visible = false
	in_game = true


func _on_restart_level():
	pass

func _on_level_completed(end_level: bool) -> void:
	signals.emit_signal("quit")

func _on_quit():
	if in_game:
		in_game = false
		_load_screensaver()
	else:
		get_tree().quit()
