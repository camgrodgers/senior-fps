extends VBoxContainer

func _ready():
	var settings = get_node("/root/Settings")
	$InvertMouseX.pressed = settings.inverse_x
	$InvertMouseY.pressed = settings.inverse_y
	$MouseSlider/HSlider.value = settings.mouse_sensitivity

func _process(delta):
	var settings = get_node("/root/Settings")
	settings.set_inverse_x($InvertMouseX.pressed)
	settings.set_inverse_y($InvertMouseY.pressed)
	settings.set_mouse_sensitivity($MouseSlider/HSlider.value)
	$MouseSlider/ValueLabel.text = "%d" % settings.mouse_sensitivity
	settings.invincibility = $Invincibility.pressed
	settings.flying = $Flying.pressed
