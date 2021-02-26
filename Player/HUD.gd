extends Control

onready var player_stats = get_parent().get_node("PlayerStats")
onready var known_cover_label: Label = $KnownCover
onready var danger_meter: TextureProgress = $RedProgress
onready var danger_meter_yellow: TextureProgress = $YellowProgress
onready var danger_meter_orange: TextureProgress = $OrangeProgress
#var crosshair_coordinates = Vector2.ZERO

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
	$CenterContainer/DeadMessage.visible = true

func _process(_delta):
	margin_right = get_viewport().size.x
	margin_bottom = get_viewport().size.y
	$CenterContainer.margin_right = get_viewport().size.x
	$CenterContainer.margin_bottom = get_viewport().size.y
#	$Crosshair.margin_top = crosshair_coordinates.y - $Crosshair.rect_size.y / 2
#	$Crosshair.margin_left = crosshair_coordinates.x - $Crosshair.rect_size.x / 2
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

var camera
var player

func update_enemy_distance_indicator():
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	var center: Control = $CenterContainer/Control
	for label in center.get_children():
		label.queue_free()

	for e in enemies:
		if e.player_danger == 0 or not e.can_see_player:
			continue
		
		var offset = e.translation - player.translation
		offset.y = 0
		offset = offset.normalized().rotated(Vector3(0, -1, 0), camera.rotation.y) * 150
		
		var label: Label = Label.new()
		center.add_child(label)
		label.margin_left = offset.x
		label.margin_top = offset.z
		label.text = "%3.1fm" % e.player_distance
		
#		last_distance = e.player_distance

