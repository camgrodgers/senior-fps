extends VBoxContainer

func _ready():
	var settings = get_node("/root/Settings")
	$InvertMouseX.pressed = settings.inverse_x
	$InvertMouseY.pressed = settings.inverse_y
	$MouseSlider/HSlider.value = settings.mouse_sensitivity
	$FOVSlider/HSlider.value = settings.fov
	$MasterVolumeSlider/HSlider.value = settings.master_volume_pct

func _process(delta):
	var settings = get_node("/root/Settings")
	settings.set_inverse_x($InvertMouseX.pressed)
	settings.set_inverse_y($InvertMouseY.pressed)
	settings.set_mouse_sensitivity($MouseSlider/HSlider.value)
	$MouseSlider/ValueLabel.text = "%d" % settings.mouse_sensitivity
	settings.set_fov($FOVSlider/HSlider.value)
	$FOVSlider/ValueLabel.text = "%d" % settings.fov
	settings.set_master_volume_percent($MasterVolumeSlider/HSlider.value)
	$MasterVolumeSlider/ValueLabel.text = "%d%%" % settings.master_volume_pct
	settings.invincibility = $Invincibility.pressed
	settings.flying = $Flying.pressed
