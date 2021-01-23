extends Control


onready var PlayerStats = get_parent().get_node("PlayerStats")


onready var DangerMeter = $ProgressBar

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
