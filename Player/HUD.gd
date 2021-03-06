extends Control

onready var player_stats = get_parent().get_node("PlayerStats")
onready var known_cover_label: Label = $KnownCover
onready var danger_meter: TextureProgress = $RedProgress
onready var danger_meter_yellow: TextureProgress = $YellowProgress
onready var danger_meter_orange: TextureProgress = $OrangeProgress
var crosshair_coordinates = Vector2.ZERO

func _ready():
	danger_meter.visible = false
	
func zoomIn():
#	$CenterContainer/Crosshair.rect_scale *= 0.5
#	$CenterContainer/Crosshair.rect_position.x += 25
	pass

func zoomOut():
#	$CenterContainer/Crosshair.rect_scale *= 2
#	$CenterContainer/Crosshair.rect_position.x -= 25
	pass

func player_dead_message():
	$CenterContainer/Label.visible = true

func _process(_delta):
	margin_right = get_viewport().size.x
	margin_bottom = get_viewport().size.y
	$CenterContainer.margin_right = get_viewport().size.x
	$CenterContainer.margin_bottom = get_viewport().size.y
	$Crosshair.margin_top = crosshair_coordinates.y - $Crosshair.rect_size.y / 2
	$Crosshair.margin_left = crosshair_coordinates.x - $Crosshair.rect_size.x / 2
	update_danger_meter()
	update_enemy_distance_indicator()
	
	known_cover_label.visible = (player_stats.known_cover_position
			and player_stats.danger_level > 0)

func update_danger_meter():
	danger_meter.value = player_stats.danger_level
	danger_meter_yellow.value = player_stats.danger_level
	danger_meter_orange.value = player_stats.danger_level_orange
	
	if player_stats.danger_level > 0:
		danger_meter.visible = true
		danger_meter_orange.visible = true
		danger_meter_yellow.visible = (player_stats.hidden_from_enemies
				and not player_stats.known_cover_position)
		
	else:
		danger_meter.visible = false
		danger_meter_yellow.visible = false
		danger_meter_orange.visible = false

class DistanceSorter:
	static func sort_ascending(a, b):
		if a.player_distance < b.player_distance:
			return true
		return false

func update_enemy_distance_indicator():
	for label in danger_meter.get_children():
		label.queue_free()

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	enemies.sort_custom(DistanceSorter, "sort_ascending")
	var last_distance: float = -10.0
	var last_height: float = 0
	for e in enemies:
		if e.player_danger == 0 or not e.world_state["can_see_player"]:
			continue
		
		var label: Label = Label.new()
		danger_meter.add_child(label)
		var label_height = -12
		if abs(e.player_distance - last_distance) < 10:
			last_height -= 10
			label_height += last_height
		else:
			last_height = 0
		label.margin_top = label_height
		label.anchor_left = clamp(e.player_distance / 100, 0.01, 0.9)
		label.text = "%3.1fm" % e.player_distance
		
		last_distance = e.player_distance

