extends Node

onready var signals = get_node("/root/Signals")

var danger_level: float = 0
var danger_level_orange: float = 0
var known_cover_position: bool = false
var hidden_from_enemies: bool = true

func _process(delta):
	danger_update(delta)

# Processes enemy and player data
func danger_update(delta):
	var player_position = get_parent().translation
	danger_level = 0
	danger_level_orange = 0
	known_cover_position = false
	hidden_from_enemies = true

	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0: return
	
	for e in enemies:
		if e.world_state["can_see_player"]:
			hidden_from_enemies = false
		if e.last_player_position.distance_to(player_position) < 6:
			known_cover_position = true

	for e in enemies:
		if ((not e.world_state["can_see_player"])
				and e.last_player_position.distance_to(player_position) < 10):
			danger_level_orange += e.player_danger

		danger_level += e.player_danger
	
	danger_level = clamp(danger_level, 0, 100)
	danger_level_orange = clamp(danger_level_orange, 0, 100)
#	signals.emit_signal("player_danger_update", danger_level)

