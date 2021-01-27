extends Control


onready var PlayerStats = get_parent().get_node("PlayerStats")


onready var DangerMeter = $ProgressBar


func _ready():
	DangerMeter.visible = false
	
func zoomIn():
	$CenterContainer/Crosshair.rect_scale *= 0.5
	$CenterContainer/Crosshair.rect_position.x += 25

func zoomOut():
	$CenterContainer/Crosshair.rect_scale *= 2
	$CenterContainer/Crosshair.rect_position.x -= 25
	
	

func _process(delta):
	margin_right = get_viewport().size.x
	margin_bottom = get_viewport().size.y
	$CenterContainer.margin_right = get_viewport().size.x
	$CenterContainer.margin_bottom = get_viewport().size.y
	update_danger_meter()
	update_enemy_distance_indicator()

func update_danger_meter():
	DangerMeter.value = PlayerStats.danger_level
	
	if PlayerStats.danger_level > 0:
		DangerMeter.visible = true
	else:
		DangerMeter.visible = false

class DistanceSorter:
	static func sort_ascending(a, b):
		if a.player_distance < b.player_distance:
			return true
		return false

func update_enemy_distance_indicator():
	for l in $ProgressBar.get_children():
		l.queue_free()

	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies.sort_custom(DistanceSorter, "sort_ascending")
	var last_distance = -10
	for e in enemies:
		if e.player_danger == 0:
			continue
		
		var label = Label.new()
		$ProgressBar.add_child(label)
		label.margin_top = -12
		if abs(e.player_distance - last_distance) < 10:
			label.margin_top = -20
		label.anchor_left = clamp(e.player_distance / 100, 0.01, 0.9)
		label.text = "%3.1fm" % e.player_distance
		
		last_distance = e.player_distance
		

	

