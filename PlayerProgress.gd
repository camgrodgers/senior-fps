extends Node

onready var signals = get_node("/root/Signals")

var levels = {
	"Canyon Infiltration": {
		 "filename": "res://Levels/CanyonInfiltration/CanyonInfiltration.tscn"
		, "completed": false
		, "best_time": -1.0
	}
	,
	"Siege": {
		 "filename": "res://Levels/CamLevel1/CamLevel1.tscn"
		, "completed": false
		, "best_time": -1.0
	}
	,
	"Jacob's Level": {
		 "filename": "res://Levels/JacobLevel1/GameLevel.tscn"
		, "completed": false
		, "best_time": -1.0
	}
	,
	"Test Level": {
		 "filename": "res://Levels/TestLevel/TestLevel.tscn"
		, "completed": false
		, "best_time": -1.0
	}
	,
	"Tutorial": {
		 "filename": "res://Levels/Tutorial/Tutorial.tscn"
		, "completed": false
		, "best_time": -1.0
	}
	,
	"Sniper's Valley": {
		 "filename": "res://Levels/SnipersValley/SnipersValley.tscn"
		, "completed": false
		, "best_time": -1.0
	}
	,
}
var save_filename = "user://save.dat"
var current_level_name = null

func _ready():
	_load_save_file()
	signals.connect("level_selected", self, "_on_level_selected")
	signals.connect("level_completed", self, "_on_level_completed")

func _on_level_selected(level_name: String):
	current_level_name = level_name
#	time_in_current_level = 0.0
#	timer_running = true

#func _on_level_completed(_end_level: bool, is_lowest_time_best: bool):
func _on_level_completed(_end_level: bool):
	levels[current_level_name]["completed"] = true
	_save_save_file()

#func _process(delta):
func clear_save_file():
	for l in levels:
		l["completed"] = false
		l["best_time"] = -1.0
	
	_save_save_file()

func _load_save_file():
	var save := File.new()
	if save.file_exists(save_filename):
		if OK == save.open(save_filename, File.READ):
			var new_progress = save.get_var()
			for k in new_progress:
				levels[k] = new_progress[k]
		else:
			return
	else:
		_save_save_file()

func _save_save_file():
	var save := File.new()
	if OK == save.open(save_filename, File.WRITE):
		save.store_var(levels)


