extends Node

var preconditions = {
	"has_target" : true,
	"in_cover": true,
	"in_range": true,
}

var effects = {
	"in_danger" : false,
	"has_target" : false
}

var cost = 1
var path_updated = false
var safety_cover_timer = 0

func move_to(enemy: Enemy, delta: float) -> bool:
	
	safety_cover_timer += delta
	if !(enemy.currentNode in enemy.coverNodes):
		enemy.replan_actions()
	if not path_updated and safety_cover_timer > 3.5:
		enemy.update_path(enemy.player.translation)
		path_updated = true
		safety_cover_timer = 0
	if path_updated:
		enemy.move_along_path(delta)
		enemy.aim_at_player(delta)
		enemy.check_vision()
	
	if enemy.world_state["can_see_player"] == true:
		enemy.ready_for_action()
		path_updated = false
		return true
	return false
	
func take_action(enemy: KinematicBody, delta: float) -> bool:
	if not enemy.check_range():
		enemy.replan_actions()
		enemy.clear_node_data()
	
	if enemy.world_state["can_see_player"]:
		enemy.shoot_around_player(delta)
	
	enemy.cover_timer += delta
	enemy.aim_at_player(delta)
	if enemy.cover_timer > 1.0:
		enemy.cover_timer = 0
		enemy.world_state["in_cover"] = false
		enemy.clear_node_data()
		enemy.go_to_next_action()
		return true
	return false
