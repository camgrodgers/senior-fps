extends Node

# Camera settings
var inverse_x: bool = false
var inverse_y: bool = false
var mouse_sensitivity: float = 15
var fov: float = 90

# Other settings
var master_volume_pct: int = 100

# Temporary settings
var invincibility: bool = false
var flying: bool = false



func _ready():
	var config: ConfigFile = ConfigFile.new()
	if OK == config.load("user://FPS_settings.cfg"):
		inverse_x = config.get_value("camera", "inverse_x", false)
		inverse_y = config.get_value("camera", "inverse_y", false)
		mouse_sensitivity = config.get_value("camera", "mouse_sensitivity", 15)
		fov = config.get_value("camera", "fov", 90)
		master_volume_pct = config.get_value("audio", "master_bus_volume", 100)
		_update_master_volume(master_volume_pct)
	else:
		save_settings_to_file()

func save_settings_to_file() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.set_value("camera", "inverse_x", inverse_x)
	config.set_value("camera", "inverse_y", inverse_y)
	config.set_value("camera", "mouse_sensitivity", mouse_sensitivity)
	config.set_value("camera", "fov", fov)
	config.set_value("audio", "master_bus_volume", master_volume_pct)
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

func set_master_volume_percent(val: float) -> void:
	if val == master_volume_pct: return
	master_volume_pct = val
	_update_master_volume(val)
	save_settings_to_file()

func _update_master_volume(val: float) -> void:
	var master_bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_index, linear2db(val / 100))
