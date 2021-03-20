extends Node

# Camera settings
var inverse_x: bool = false
var inverse_y: bool = false
var mouse_sensitivity: float = 15
var fov: float = 90

# Temporary settings
var invincibility: bool = false
var flying: bool = false

func _ready():
	var config: ConfigFile = ConfigFile.new()
	if OK == config.load("user://FPS_settings.cfg"):
		inverse_x = config.get_value("camera", "inverse_x", false)
		inverse_y = config.get_value("camera", "inverse_y", false)
		mouse_sensitivity = config.get_value("camera", "mouse_sensitivity", 15)
	else:
		save_settings_to_file()

func save_settings_to_file() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("camera", "inverse_x", inverse_x)
	config.set_value("camera", "inverse_y", inverse_y)
	config.set_value("camera", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("camera", "fov", mouse_sensitivity)
	config.save("user://FPS_settings.cfg")

func set_inverse_x(val: bool) -> void:
	if val == inverse_x: return
	inverse_x = val
	save_settings_to_file()
	
func set_inverse_y(val: bool) -> void:
	if val == inverse_y: return
	inverse_y = val
	save_settings_to_file()
	
func set_mouse_sensitivity(val: float) -> void:
	if val == mouse_sensitivity: return
	mouse_sensitivity = val
	save_settings_to_file()

func set_fov(val: float) -> void:
	if val == fov: return
	fov = val
	save_settings_to_file()
