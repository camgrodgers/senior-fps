extends Control

onready var player_stats = get_parent().get_node("PlayerStats")
onready var known_cover_label: Label = $KnownCover
onready var danger_meter: ProgressBar = $ProgressBar

func _ready():
	danger_meter.visible = false
	
func zoomIn():
	$CenterContainer/Crosshair.rect_scale *= 0.5
	$CenterContainer/Crosshair.rect_position.x += 25

func zoomOut():
	$CenterContainer/Crosshair.rect_scale *= 2
	$CenterContainer/Crosshair.rect_position.x -= 25

func player_dead_message():
	$CenterContainer/Label.visible = true

func _process(_delta):
	margin_right = get_viewport().size.x
	margin_bottom = get_viewport().size.y
	$CenterContainer.margin_right = get_viewport().size.x
	$CenterContainer.margin_bottom = get_viewport().size.y
	update_danger_meter()
	update_enemy_distance_indicator()
	
	known_cover_label.visible = player_stats.known_cover_position

func update_danger_meter():
	danger_meter.value = player_stats.danger_level
	
	if player_stats.danger_level > 0:
		danger_meter.visible = true
	else:
		danger_meter.visible = false

class DistanceSorter:
	static func sort_ascending(a, b):
		if a.player_distance < b.player_distance:
			return true
		return false

func update_enemy_distance_indicator():
	for label in $ProgressBar.get_children():
		label.queue_free()

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	enemies.sort_custom(DistanceSorter, "sort_ascending")
	var last_distance: float = -10.0
	for e in enemies:
		if e.player_danger == 0 or not e.can_see_player:
			continue
		
		var label: Label = Label.new()
		$ProgressBar.add_child(label)
		label.margin_top = -12
		if abs(e.player_distance - last_distance) < 10:
			label.margin_top = -20
		label.anchor_left = clamp(e.player_distance / 100, 0.01, 0.9)
		label.text = "%3.1fm" % e.player_distance
		
		last_distance = e.player_distance

