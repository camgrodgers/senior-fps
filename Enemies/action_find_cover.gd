extends Node

var preconditions = {
	"in_cover": false,
	"in_range": true,
}

var effects = {
	"in_cover" : true
}

var cost = 1
var path_updated = false


func move_to(enemy: KinematicBody, delta: float) -> bool:
	if get_tree().get_nodes_in_group("navnodes_not_seen_by_player").empty():
		enemy.ready_for_action()
		path_updated = false
		return true
	if not path_updated:
		enemy.prep_node(enemy.get_shortest_node())
		path_updated = true
	enemy.move_along_path(delta)
	enemy.aim_at_player(delta)
	if enemy.check_vision():
		enemy.shoot_around_player(delta)
	
	if enemy.path.empty():
		enemy.ready_for_action()
		path_updated = false
		return true
	return false

func take_action(enemy: KinematicBody, delta: float):
	enemy.world_state["in_cover"] = true
	enemy.go_to_next_action()
