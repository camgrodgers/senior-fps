extends Control
class_name Menu

signal level_selected(filename)

onready var main = get_parent()
onready var resume = $MarginContainer/HBoxContainer/Buttons/Resume
onready var restart = $MarginContainer/HBoxContainer/Buttons/Restart
onready var level_select_menu = $MarginContainer/HBoxContainer/VBoxContainer/LevelSelectMenu

func _process(delta):
	resume.visible = main.in_game
	restart.visible = main.in_game
	
	
	if not main.in_game: return

	if Input.is_action_just_pressed("escape"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			self.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			self.visible = false



func _on_LevelSelectMenu_level_selected(filename):
	emit_signal("level_selected", filename)


func _on_LevelSelect_pressed():
	level_select_menu.visible = not level_select_menu.visible
