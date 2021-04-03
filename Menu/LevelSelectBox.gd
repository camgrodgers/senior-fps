extends PanelContainer
class_name LevelSelectBox

onready var signals = get_node("/root/Signals")
onready var progress = get_node("/root/PlayerProgress")

export(String) var level_name = ""
var level_name_valid: bool = false
var level_order_number: int = 0

func _ready():
	signals.connect("level_completed", self, "_on_level_completed")
	if progress.levels.has(level_name):
		_update_text()
		level_name_valid = true
	else:
		_mark_invalid()

#func _process(delta):
#	if not level_name_valid:
#		self.set_process(false)
#		return
#
#	_update_text()

func _on_level_completed(_end_level: bool):
	_update_text()

func _update_text():
	$VBoxContainer/Button.text = "%02d - %s" % [level_order_number, level_name]
	$VBoxContainer/HBoxContainer/CompletionLabel.text = (
		"Level beaten!" if progress.levels[level_name]["completed"]
			else "Level not beaten."
	)
	var best_time = progress.levels[level_name]["best_time"]
	$VBoxContainer/HBoxContainer/TimeLabel.text = (
		"%f seconds" % [best_time] if best_time > 0 else "--- seconds" 
	)

func _mark_invalid():
	$VBoxContainer/Button.text = "Invalid level name"
	level_name_valid = false

func _on_Button_pressed():
	if level_name_valid:
		signals.emit_signal("level_selected", level_name)
