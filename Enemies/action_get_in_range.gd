extends Node

var preconditions = {
	"in_range": false,
}

var effects = {
	"in_range" : true
}

var cost = 1
var path_updated = false
var last_player_position = null


func move_to(enemy: KinematicBody, delta: float) -> bool:
	
	if not path_updated or last_player_position.distance_to(enemy.player.translation) > 10:
		enemy.update_path(enemy.player.translation)
		last_player_position = enemy.player.translation
		enemy.world_state["in_cover"] = false
		path_updated = true
	enemy.move_along_path(delta)
	enemy.aim_at_player(delta)
	
	if enemy.check_range():
		enemy.ready_for_action()
		path_updated = false
		return true
	return false

func take_action(enemy: KinematicBody, delta: float):
	enemy.go_to_next_action()
