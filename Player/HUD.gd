extends Control


onready var PlayerStats = get_parent().get_node("PlayerStats")


onready var DangerMeter = $ProgressBar


func _ready():
	DangerMeter.visible = false
	

func _process(delta):
	update_danger_meter(delta)

func update_danger_meter(delta):
	DangerMeter.value = PlayerStats.danger_level
	
	if PlayerStats.danger_level > 0:
		DangerMeter.visible = true
	else:
		DangerMeter.visible = false
