extends Control
class_name Menu

signal level_selected(filename)
signal restart_level()
signal quit()

onready var main = get_parent()
onready var resume = $MarginContainer/HBoxContainer/Buttons/Resume
onready var restart = $MarginContainer/HBoxContainer/Buttons/Restart
onready var level_select_menu = $MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/LevelSelectMenu
onready var settings_menu = $MarginContainer/HBoxContainer/PanelContainer/VBoxContainer/SettingsMenu

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
	_resume()


func _on_LevelSelect_pressed():
	level_select_menu.visible = not level_select_menu.visible
	$MarginContainer/HBoxContainer/PanelContainer.visible = level_select_menu.visible
	settings_menu.visible = false

func _on_Settings_pressed():
	settings_menu.visible = not settings_menu.visible
	$MarginContainer/HBoxContainer/PanelContainer.visible = settings_menu.visible
	level_select_menu.visible = false

func _on_Resume_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false
	get_tree().paused = false

func _resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.visible = false
	get_tree().paused = false

func _on_Restart_pressed():
	emit_signal("restart_level")
	_resume()


func _on_Quit_pressed():
	emit_signal("quit")


