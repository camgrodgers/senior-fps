extends Control


onready var PlayerStats = get_parent().get_node("PlayerStats")


onready var DangerMeter = $ProgressBar

<<<<<<< Updated upstream
=======
func zoomIn():
	$CenterContainer/Crosshair.rect_scale *= 2
	$CenterContainer/Crosshair.rect_position.x -= 25
	
func zoomOut():
	$CenterContainer/Crosshair.rect_scale *= 0.5
	$CenterContainer/Crosshair.rect_position.x += 25


>>>>>>> Stashed changes
func _ready():
	DangerMeter.visible = false
	

func _process(delta):
	margin_right = get_viewport().size.x
	margin_bottom = get_viewport().size.y
	$CenterContainer.margin_right = get_viewport().size.x
	$CenterContainer.margin_bottom = get_viewport().size.y
	update_danger_meter(delta)

func update_danger_meter(delta):
	DangerMeter.value = PlayerStats.danger_level
	
	if PlayerStats.danger_level > 0:
		DangerMeter.visible = true
	else:
		DangerMeter.visible = false
